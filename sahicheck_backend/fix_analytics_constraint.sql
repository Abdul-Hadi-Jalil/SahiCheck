-- Fix for analytics table missing unique constraint
-- Run this in pgAdmin connected to sahicheck database

-- Add the unique constraint to sahicheck_schema.analytics (needed for ON CONFLICT upsert)
ALTER TABLE sahicheck_schema.analytics 
ADD CONSTRAINT analytics_user_endpoint_date_key 
UNIQUE (user_id, endpoint, date);