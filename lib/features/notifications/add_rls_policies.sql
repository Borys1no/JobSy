-- Habilitar RLS en la tabla notifications
alter table notifications enable row level security;

-- Política para que los usuarios vean solo sus propias notificaciones
create policy "Users can view their own notifications"
  on notifications for select
  using (auth.uid() = user_id);

-- Política para que los usuarios actualicen solo sus propias notificaciones (marcar como leída)
create policy "Users can update their own notifications"
  on notifications for update
  using (auth.uid() = user_id);

-- Política para permitir insertar notificaciones (necesario para que el sistema cree notificaciones)
create policy "Allow authenticated users to insert notifications"
  on notifications for insert
  with check (auth.role() = 'authenticated');

-- Verificar que Realtime está habilitado para la tabla notifications
begin;
  drop publication if exists supabase_realtime;
  create publication supabase_realtime for table notifications;
commit;
