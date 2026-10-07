import { createContext, useContext, type ReactNode } from 'react'
import { supabase } from '../lib/supabase'

export interface SessionUser {
  id: string
  email?: string
}

interface AuthState {
  user: SessionUser | null
  isAdmin: boolean
  loading: boolean
}

const AuthContext = createContext<AuthState>({
  user: null,
  isAdmin: false,
  loading: true,
})

/**
 * Walking-skeleton auth context.
 *
 * Live Supabase wiring (a `good first issue`):
 *   1. npm i @supabase/supabase-js and enable createClient in lib/supabase.ts
 *   2. const { data } = await supabase.auth.getSession()  -> hydrate user
 *   3. supabase.auth.onAuthStateChange((_event, session) => setUser(...))
 *   4. isAdmin: read public.admin_roles for user.id (SELECT policy exists
 *      for self rows in supabase/migrations/0001_init.sql)
 * Until then the app renders with user = null and an offline demo banner.
 */
export function AuthProvider({ children }: { children: ReactNode }) {
  // Walking-skeleton state: real session wiring is the first `good first issue`.
  const user: SessionUser | null = null
  const isAdmin = false
  const loading = false

  // Live wiring (npm i @supabase/supababase-js in lib/supabase.ts first):
  //   supabase.auth.getSession() -> hydrate user
  //   supabase.auth.onAuthStateChange((_e, s) => setUser(s?.user ?? null))
  void supabase // placeholder import stays tree-shakeable until then

  return (
    <AuthContext.Provider value={{ user, isAdmin, loading }}>{children}</AuthContext.Provider>
  )
}

// eslint-disable-next-line react-refresh/only-export-components
export function useAuth() {
  return useContext(AuthContext)
}
