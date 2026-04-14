alter table worker_profiles 
add column if not exists address text,
add column if not exists bio text,
add column if not exists languages text[],
add column if not exists certifications text[],
add column if not exists bank_name text,
add column if not exists bank_account text,
add column if not exists privacy_setting text default 'public';