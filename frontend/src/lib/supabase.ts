/**
 * Shared Supabase wiring - the ONLY place in the app that touches Supabase.
 *
 * The anon key is public by design; every table is protected by Row Level
 * Security (see docs/rls.md). Never import the service_role key here.
 *
 * Walking-skeleton state: env vars are read and typed now, but createClient is
 * not wired yet. The first `good first issue` flips it on end-to-end.
 */

type Env = {
  VITE_SUPABASE_URL?: string
  VITE_SUPABASE_ANON_KEY?: string
}

const env = import.meta.env as Env

export const supabaseConfig = {
  url: env.VITE_SUPABASE_URL ?? 'https://placeholder.supabase.co',
  anonKey: env.VITE_SUPABASE_ANON_KEY ?? 'public-anon-key-placeholder',
}

if (!env.VITE_SUPABASE_URL || !env.VITE_SUPABASE_ANON_KEY) {
  // Walking skeleton: app stays renderable without credentials, but be loud.
  console.warn(
    '[DevBridge] Missing VITE_SUPABASE_URL / VITE_SUPABASE_ANON_KEY - using placeholders. ' +
      'Copy .env.example to .env first.',
  )
}

export const supabase = {
  from: (table: string) => ({ table }),
  rpc: (fn: string) => ({ fn }),
  // Real Supabase wiring (a `good first issue`):
  // import { createClient } from '@supabase/supabase-js'
  // export const supabase = createClient(supabaseConfig.url, supabaseConfig.anonKey)
}

export type SupabaseTable = ReturnType<typeof supabase.from>
