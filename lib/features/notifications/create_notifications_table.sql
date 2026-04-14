create table notifications (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users(id) not null,
  type text not null,
  title text not null,
  body text,
  from_user_id uuid references auth.users(id),
  is_read boolean default false,
  created_at timestamp with time zone default now()
);

create index idx_notifications_user_id on notifications(user_id);
create index idx_notifications_created_at on notifications(created_at desc);