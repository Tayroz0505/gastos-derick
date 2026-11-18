-- Rode isto uma vez no Supabase: SQL Editor > New query > colar > Run.
create table if not exists public.gastos (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  valor numeric(12,2) not null check (valor > 0),
  categoria text not null,
  data date not null default current_date,
  descricao text not null default '',
  criado_em timestamptz not null default now()
);

create index if not exists gastos_user_data_idx on public.gastos (user_id, data desc);

-- Cada pessoa logada só vê e mexe nos próprios gastos.
alter table public.gastos enable row level security;

drop policy if exists "ver os proprios gastos" on public.gastos;
create policy "ver os proprios gastos" on public.gastos
  for select to authenticated using (auth.uid() = user_id);

drop policy if exists "anotar os proprios gastos" on public.gastos;
create policy "anotar os proprios gastos" on public.gastos
  for insert to authenticated with check (auth.uid() = user_id);

drop policy if exists "alterar os proprios gastos" on public.gastos;
create policy "alterar os proprios gastos" on public.gastos
  for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "apagar os proprios gastos" on public.gastos;
create policy "apagar os proprios gastos" on public.gastos
  for delete to authenticated using (auth.uid() = user_id);
