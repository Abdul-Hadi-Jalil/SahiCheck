import pandas as pd
import numpy as np
import nltk
import spacy
import matplotlib.pyplot as plt

from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords
from gensim.models import Word2Vec
from sklearn.model_selection import train_test_split
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Input, Dropout
from tensorflow.keras.callbacks import EarlyStopping

nltk.download('punkt_tab')
nltk.download('stopwords')

"""### Load Dataset"""

fake = pd.read_csv('/content/Fake.csv', engine='python', quotechar='"', on_bad_lines='warn')
real = pd.read_csv('/content/True.csv', engine='python', quotechar='"', on_bad_lines='warn')

"""### Label"""

fake['label'] = 0
real['label'] = 1

df = pd.concat([fake, real], ignore_index=True)
df = df.dropna(subset=['text'])
df = df.sample(frac=1, random_state=42).reset_index(drop=True)

"""### Load SpaCy Model | Load Stopwords | Lowercase |Tokenization | Lemmatization"""

nlp = spacy.load("en_core_web_sm", disable=["parser", "ner"])
stop_words = set(stopwords.words('english'))

processed_data = []

for text in df['text']:
    text = text.lower()

    tokens = word_tokenize(text)
    tokens = [w for w in tokens if w.isalpha() and w not in stop_words]

    doc = nlp(" ".join(tokens))
    lemmas = [token.lemma_ for token in doc]

    processed_data.append(lemmas)

"""### Word2Vec Model"""

w2v_model = Word2Vec(
    sentences=processed_data,
    vector_size=200,
    window=7,
    min_count=3,
    workers=4
)

"""### Convert Text → Vector"""

def get_vector(tokens):
    vectors = [w2v_model.wv[word] for word in tokens if word in w2v_model.wv]
    if len(vectors) == 0:
        return np.zeros(200)
    return np.mean(vectors, axis=0)

X = np.array([get_vector(tokens) for tokens in processed_data])
y = df['label'].values

"""### Train-Test Split"""

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

"""### Neural Network"""

model = Sequential()

model.add(Input(shape=(200,)))
model.add(Dense(256, activation='relu'))
model.add(Dropout(0.4))

model.add(Dense(128, activation='relu'))
model.add(Dropout(0.4))

model.add(Dense(128, activation='relu'))
model.add(Dense(1, activation='sigmoid'))

"""### Compile Model"""

model.compile(
    optimizer='adam',
    loss='binary_crossentropy',
    metrics=['accuracy']
)

"""### Training"""

history = model.fit(
    X_train, y_train,
    epochs=15,
    batch_size=32,
    validation_split=0.2,

)

loss, acc = model.evaluate(X_test, y_test)
print("Test Accuracy:", acc)

model.save('fake_news_detector_model.keras')
print("Model saved as 'fake_news_detector_model.keras'")

"""### Accuracy Vs Val_accuracy"""

plt.figure()
plt.plot(history.history['accuracy'])
plt.plot(history.history['val_accuracy'])
plt.title('Model Accuracy')
plt.xlabel('Epoch')
plt.ylabel('Accuracy')
plt.legend(['Train', 'Validation'])
plt.show()

"""### Loss Vs Val_loss"""

plt.figure()
plt.plot(history.history['loss'])
plt.plot(history.history['val_loss'])
plt.title('Model Loss')
plt.xlabel('Epoch')
plt.ylabel('Loss')
plt.legend(['Train', 'Validation'])
plt.show()