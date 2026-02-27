-- Hellenic Actuarial Society - Supabase Database Schema
-- Paste this script into the Supabase SQL Editor and click "Run"

-- 1. Create Members Table (extends the built-in auth.users table)
CREATE TABLE public.members (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    full_name TEXT NOT NULL,
    certification_level TEXT CHECK (certification_level IN ('None', 'THAS', 'AHAS', 'FHAS', 'CERA')) DEFAULT 'None',
    member_since DATE DEFAULT CURRENT_DATE,
    subscription_status TEXT CHECK (subscription_status IN ('Active', 'Pending', 'Overdue')) DEFAULT 'Pending',
    required_cpd_hours INTEGER DEFAULT 30,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Protect the members table with Row Level Security (RLS)
ALTER TABLE public.members ENABLE ROW LEVEL SECURITY;

-- Allow users to read only their own member profile
CREATE POLICY "Users can view their own profile" 
ON public.members FOR SELECT 
USING (auth.uid() = id);

-- Allow users to update their own member profile
CREATE POLICY "Users can update their own profile" 
ON public.members FOR UPDATE 
USING (auth.uid() = id);


-- 2. Create CPD Logs Table
CREATE TABLE public.cpd_logs (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    member_id UUID REFERENCES public.members(id) ON DELETE CASCADE NOT NULL,
    activity_name TEXT NOT NULL,
    provider TEXT NOT NULL,
    completion_date DATE NOT NULL,
    hours NUMERIC(5, 2) NOT NULL,
    status TEXT CHECK (status IN ('Verified', 'Pending Review', 'Rejected')) DEFAULT 'Pending Review',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Protect the cpd_logs table
ALTER TABLE public.cpd_logs ENABLE ROW LEVEL SECURITY;

-- Allow users to manage their own CPD logs
CREATE POLICY "Users can manage their own cpd logs" 
ON public.cpd_logs FOR ALL 
USING (auth.uid() = member_id);


-- 3. Create Transactions Table (For Exams & Subscriptions)
CREATE TABLE public.transactions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    member_id UUID REFERENCES public.members(id) ON DELETE CASCADE NOT NULL,
    transaction_type TEXT CHECK (transaction_type IN ('Annual Subscription', 'Exam Application', 'Seminar Fee')) NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    stripe_session_id TEXT UNIQUE,
    payment_status TEXT CHECK (payment_status IN ('Completed', 'Pending', 'Failed')) DEFAULT 'Pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Protect the transactions table
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

-- Allow users to view their own transactions
CREATE POLICY "Users can view their own transactions" 
ON public.transactions FOR SELECT 
USING (auth.uid() = member_id);

-- NOTE: Transactions are usually inserted by the secure backend/webhook, so we don't allow users to INSERT directly.

-- 4. Create a trigger to automatically create a member profile when a new user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.members (id, full_name, certification_level)
  VALUES (new.id, COALESCE(new.raw_user_meta_data->>'full_name', 'New Member'), 'None');
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
