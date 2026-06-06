create extension if not exists pgcrypto;

create table if not exists public.polla_app_state (
  id boolean primary key default true check (id),
  state jsonb not null,
  updated_at timestamptz not null default now()
);

alter table public.polla_app_state enable row level security;

insert into public.polla_app_state (id, state)
select true, jsonb_build_object(
  'users', to_jsonb(users.names),
  'passwords', users.passwords,
  'adminPassword', 'admin2026',
  'settings', jsonb_build_object('predictionsUnlocked', false),
  'customMatches', '[]'::jsonb,
  'predictions', '{}'::jsonb,
  'results', '{}'::jsonb
)
from (
  select
    array_agg('Jugador ' || lpad(i::text, 2, '0') order by i) as names,
    jsonb_object_agg('Jugador ' || lpad(i::text, 2, '0'), 'jugador2026' order by i) as passwords
  from generate_series(1, 50) as i
) users
on conflict (id) do nothing;

create or replace function public.get_login_options()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  app jsonb;
begin
  select state into app from public.polla_app_state where id = true;
  return jsonb_build_object('users', app->'users');
end;
$$;

create or replace function public.login_and_state(p_user text, p_password text, p_admin boolean)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  app jsonb;
  clean_state jsonb;
begin
  select state into app from public.polla_app_state where id = true;

  if p_admin then
    if p_user = 'Administrador' and p_password = app->>'adminPassword' then
      return jsonb_build_object('ok', true, 'state', app);
    end if;
    return jsonb_build_object('ok', false, 'message', 'Clave admin incorrecta');
  end if;

  if coalesce(app->'passwords'->>p_user, '') = p_password then
    clean_state := app - 'passwords';
    clean_state := jsonb_set(clean_state, '{adminPassword}', '""'::jsonb, true);
    return jsonb_build_object('ok', true, 'state', clean_state);
  end if;

  return jsonb_build_object('ok', false, 'message', 'Contraseña incorrecta');
end;
$$;

create or replace function public.save_user_predictions(p_user text, p_password text, p_predictions jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  app jsonb;
begin
  select state into app from public.polla_app_state where id = true for update;

  if coalesce(app->'passwords'->>p_user, '') <> p_password then
    return jsonb_build_object('ok', false, 'message', 'Contraseña incorrecta');
  end if;

  update public.polla_app_state
  set state = jsonb_set(app, array['predictions', p_user], coalesce(p_predictions, '{}'::jsonb), true),
      updated_at = now()
  where id = true;

  return jsonb_build_object('ok', true);
end;
$$;

create or replace function public.save_admin_state(p_password text, p_state jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  app jsonb;
begin
  select state into app from public.polla_app_state where id = true for update;

  if coalesce(app->>'adminPassword', '') <> p_password then
    return jsonb_build_object('ok', false, 'message', 'Clave admin incorrecta');
  end if;

  update public.polla_app_state
  set state = p_state,
      updated_at = now()
  where id = true;

  return jsonb_build_object('ok', true);
end;
$$;

grant execute on function public.get_login_options() to anon, authenticated;
grant execute on function public.login_and_state(text, text, boolean) to anon, authenticated;
grant execute on function public.save_user_predictions(text, text, jsonb) to anon, authenticated;
grant execute on function public.save_admin_state(text, jsonb) to anon, authenticated;
