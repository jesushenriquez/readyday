-- ReadyDay Supabase Schema Migration
-- Run this in Supabase SQL Editor
-- Version: 1.0 (Sprint 1)

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- Table: users
-- ============================================
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    supabase_auth_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
    whoop_user_id BIGINT,
    email TEXT,
    display_name TEXT,
    timezone TEXT NOT NULL DEFAULT 'America/Los_Angeles',
    morning_briefing_time TIME NOT NULL DEFAULT '07:00:00',
    onboarding_completed BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for auth lookup
CREATE INDEX IF NOT EXISTS idx_users_auth_id ON users(supabase_auth_id);

-- RLS for users table
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
    ON users FOR SELECT
    USING (supabase_auth_id = auth.uid());

CREATE POLICY "Users can update own profile"
    ON users FOR UPDATE
    USING (supabase_auth_id = auth.uid());

CREATE POLICY "Users can insert own profile"
    ON users FOR INSERT
    WITH CHECK (supabase_auth_id = auth.uid());

-- ============================================
-- Table: whoop_tokens
-- ============================================
CREATE TABLE IF NOT EXISTS whoop_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    access_token TEXT NOT NULL,
    refresh_token TEXT NOT NULL,
    token_expires_at TIMESTAMPTZ NOT NULL,
    scopes TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id)
);

-- Index for user lookup
CREATE INDEX IF NOT EXISTS idx_whoop_tokens_user_id ON whoop_tokens(user_id);

-- RLS for whoop_tokens table
ALTER TABLE whoop_tokens ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own Whoop tokens"
    ON whoop_tokens FOR ALL
    USING (user_id IN (
        SELECT id FROM users WHERE supabase_auth_id = auth.uid()
    ));

-- ============================================
-- Table: recovery_data
-- ============================================
CREATE TABLE IF NOT EXISTS recovery_data (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    whoop_cycle_id BIGINT NOT NULL,
    score_state TEXT NOT NULL, -- 'SCORED', 'PENDING_SCORE', 'UNSCORABLE'
    recovery_score INTEGER, -- 0-100
    resting_heart_rate INTEGER,
    hrv_rmssd_milli DOUBLE PRECISION,
    spo2_percentage DOUBLE PRECISION,
    skin_temp_celsius DOUBLE PRECISION,
    user_calibrating BOOLEAN NOT NULL DEFAULT FALSE,
    recorded_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, whoop_cycle_id)
);

-- Indexes for time-series queries
CREATE INDEX IF NOT EXISTS idx_recovery_user_recorded ON recovery_data(user_id, recorded_at DESC);
CREATE INDEX IF NOT EXISTS idx_recovery_user_cycle ON recovery_data(user_id, whoop_cycle_id);

-- RLS for recovery_data table
ALTER TABLE recovery_data ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own recovery data"
    ON recovery_data FOR SELECT
    USING (user_id IN (
        SELECT id FROM users WHERE supabase_auth_id = auth.uid()
    ));

CREATE POLICY "Users can insert own recovery data"
    ON recovery_data FOR INSERT
    WITH CHECK (user_id IN (
        SELECT id FROM users WHERE supabase_auth_id = auth.uid()
    ));

CREATE POLICY "Users can update own recovery data"
    ON recovery_data FOR UPDATE
    USING (user_id IN (
        SELECT id FROM users WHERE supabase_auth_id = auth.uid()
    ));

-- ============================================
-- Table: sleep_data
-- ============================================
CREATE TABLE IF NOT EXISTS sleep_data (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    whoop_sleep_id BIGINT NOT NULL,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    is_nap BOOLEAN NOT NULL DEFAULT FALSE,
    score_state TEXT NOT NULL,
    stage_summary JSONB, -- { total_in_bed_ms, total_awake_ms, total_light_ms, total_slow_wave_ms, total_rem_ms, ... }
    sleep_needed_ms BIGINT,
    sleep_debt_ms BIGINT,
    sleep_efficiency DOUBLE PRECISION,
    sleep_consistency INTEGER, -- 0-100
    respiratory_rate DOUBLE PRECISION,
    recorded_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, whoop_sleep_id)
);

-- Indexes for time-series queries
CREATE INDEX IF NOT EXISTS idx_sleep_user_recorded ON sleep_data(user_id, recorded_at DESC);
CREATE INDEX IF NOT EXISTS idx_sleep_user_sleep_id ON sleep_data(user_id, whoop_sleep_id);
CREATE INDEX IF NOT EXISTS idx_sleep_start_time ON sleep_data(user_id, start_time DESC);

-- RLS for sleep_data table
ALTER TABLE sleep_data ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own sleep data"
    ON sleep_data FOR SELECT
    USING (user_id IN (
        SELECT id FROM users WHERE supabase_auth_id = auth.uid()
    ));

CREATE POLICY "Users can insert own sleep data"
    ON sleep_data FOR INSERT
    WITH CHECK (user_id IN (
        SELECT id FROM users WHERE supabase_auth_id = auth.uid()
    ));

CREATE POLICY "Users can update own sleep data"
    ON sleep_data FOR UPDATE
    USING (user_id IN (
        SELECT id FROM users WHERE supabase_auth_id = auth.uid()
    ));

-- ============================================
-- Table: workout_data
-- ============================================
CREATE TABLE IF NOT EXISTS workout_data (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    whoop_workout_id BIGINT NOT NULL,
    sport_name TEXT NOT NULL,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    score_state TEXT NOT NULL,
    strain DOUBLE PRECISION,
    average_heart_rate INTEGER,
    max_heart_rate INTEGER,
    kilojoule DOUBLE PRECISION,
    distance_meter DOUBLE PRECISION,
    zone_durations JSONB, -- { zone_zero_ms, zone_one_ms, zone_two_ms, zone_three_ms, zone_four_ms, zone_five_ms }
    recorded_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, whoop_workout_id)
);

-- Indexes for time-series queries
CREATE INDEX IF NOT EXISTS idx_workout_user_recorded ON workout_data(user_id, recorded_at DESC);
CREATE INDEX IF NOT EXISTS idx_workout_user_workout_id ON workout_data(user_id, whoop_workout_id);
CREATE INDEX IF NOT EXISTS idx_workout_start_time ON workout_data(user_id, start_time DESC);

-- RLS for workout_data table
ALTER TABLE workout_data ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own workout data"
    ON workout_data FOR SELECT
    USING (user_id IN (
        SELECT id FROM users WHERE supabase_auth_id = auth.uid()
    ));

CREATE POLICY "Users can insert own workout data"
    ON workout_data FOR INSERT
    WITH CHECK (user_id IN (
        SELECT id FROM users WHERE supabase_auth_id = auth.uid()
    ));

CREATE POLICY "Users can update own workout data"
    ON workout_data FOR UPDATE
    USING (user_id IN (
        SELECT id FROM users WHERE supabase_auth_id = auth.uid()
    ));

-- ============================================
-- Table: daily_briefings
-- ============================================
CREATE TABLE IF NOT EXISTS daily_briefings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    briefing_date DATE NOT NULL,
    recovery_zone TEXT NOT NULL, -- 'GREEN', 'YELLOW', 'RED'
    recovery_score INTEGER,
    recommendations JSONB, -- Array of recommendation objects
    calendar_load_score INTEGER, -- 0-100, custom metric
    event_count INTEGER NOT NULL DEFAULT 0,
    high_demand_event_count INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, briefing_date)
);

-- Indexes for date queries
CREATE INDEX IF NOT EXISTS idx_briefing_user_date ON daily_briefings(user_id, briefing_date DESC);

-- RLS for daily_briefings table
ALTER TABLE daily_briefings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own briefings"
    ON daily_briefings FOR SELECT
    USING (user_id IN (
        SELECT id FROM users WHERE supabase_auth_id = auth.uid()
    ));

CREATE POLICY "Users can insert own briefings"
    ON daily_briefings FOR INSERT
    WITH CHECK (user_id IN (
        SELECT id FROM users WHERE supabase_auth_id = auth.uid()
    ));

CREATE POLICY "Users can update own briefings"
    ON daily_briefings FOR UPDATE
    USING (user_id IN (
        SELECT id FROM users WHERE supabase_auth_id = auth.uid()
    ));

-- ============================================
-- Table: user_preferences
-- ============================================
CREATE TABLE IF NOT EXISTS user_preferences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- Notification settings
    enable_morning_briefing BOOLEAN NOT NULL DEFAULT TRUE,
    enable_recovery_alerts BOOLEAN NOT NULL DEFAULT TRUE,
    enable_workout_suggestions BOOLEAN NOT NULL DEFAULT TRUE,
    enable_calendar_conflicts BOOLEAN NOT NULL DEFAULT TRUE,

    -- Calendar settings
    selected_calendar_ids TEXT[], -- Array of EKCalendar identifiers

    -- Workout settings
    workout_prep_time_minutes INTEGER NOT NULL DEFAULT 15,
    preferred_workout_times JSONB, -- Array of time windows

    -- Locale
    language TEXT NOT NULL DEFAULT 'en',

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id)
);

-- Index for user lookup
CREATE INDEX IF NOT EXISTS idx_preferences_user_id ON user_preferences(user_id);

-- RLS for user_preferences table
ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own preferences"
    ON user_preferences FOR ALL
    USING (user_id IN (
        SELECT id FROM users WHERE supabase_auth_id = auth.uid()
    ));

-- ============================================
-- Database Functions
-- ============================================

-- Function: get_latest_recovery
-- Returns the most recent recovery data for a user
CREATE OR REPLACE FUNCTION get_latest_recovery(p_user_id UUID)
RETURNS TABLE (
    recovery_score INTEGER,
    score_state TEXT,
    resting_heart_rate INTEGER,
    hrv_rmssd_milli DOUBLE PRECISION,
    recorded_at TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        rd.recovery_score,
        rd.score_state,
        rd.resting_heart_rate,
        rd.hrv_rmssd_milli,
        rd.recorded_at
    FROM recovery_data rd
    WHERE rd.user_id = p_user_id
    ORDER BY rd.recorded_at DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function: get_recovery_trend
-- Returns recovery scores for the last N days
CREATE OR REPLACE FUNCTION get_recovery_trend(p_user_id UUID, p_days INTEGER DEFAULT 7)
RETURNS TABLE (
    recovery_score INTEGER,
    recorded_at TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        rd.recovery_score,
        rd.recorded_at
    FROM recovery_data rd
    WHERE rd.user_id = p_user_id
        AND rd.recorded_at >= NOW() - (p_days || ' days')::INTERVAL
        AND rd.recovery_score IS NOT NULL
    ORDER BY rd.recorded_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- Triggers for updated_at
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_whoop_tokens_updated_at BEFORE UPDATE ON whoop_tokens
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_daily_briefings_updated_at BEFORE UPDATE ON daily_briefings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_preferences_updated_at BEFORE UPDATE ON user_preferences
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- End of migrations
-- ============================================
