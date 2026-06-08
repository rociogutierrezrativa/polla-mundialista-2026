create or replace function public.change_user_password(
  p_user text,
  p_current_password text,
  p_new_password text
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  app jsonb;
begin
  if coalesce(trim(p_new_password), '') = '' then
    return jsonb_build_object('ok', false, 'message', 'La nueva contraseña no puede estar vacía');
  end if;

  select state into app from public.polla_app_state where id = true for update;

  if coalesce(app->'passwords'->>p_user, '') <> p_current_password then
    return jsonb_build_object('ok', false, 'message', 'Contraseña actual incorrecta');
  end if;

  update public.polla_app_state
  set state = jsonb_set(app, array['passwords', p_user], to_jsonb(p_new_password), true),
      updated_at = now()
  where id = true;

  return jsonb_build_object('ok', true);
end;
$$;

grant execute on function public.change_user_password(text, text, text) to anon, authenticated;
