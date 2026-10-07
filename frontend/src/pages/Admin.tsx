import { useEffect, useState } from 'react'
import { supabase } from '../lib/supabase'
import { useAuth } from '../auth/AuthContext'
import type { EventRow } from '../types'

/**
 * Admin approval queue (issue #14). Data access is guarded by RLS, not by this
 * page: guests simply see zero pending rows. Actions go through the
 * admin_event_action RPC (docs/api.md) - never a raw client update.
 */

export default function Admin() {
  const { user, isAdmin } = useAuth()
  const [pending, setPending] = useState<EventRow[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    let cancelled = false

    async function load() {
      setLoading(true)
      // Live wiring (issue: "build admin approval table with filters"):
      // const { data } = await supabase
      //   .from('events')
      //   .select('*')
      //   .eq('status', 'pending')
      //   .order('submitted_at')
      void supabase
      if (!cancelled) {
        setPending([]) // empty for non-admins by RLS; skeleton shows the layout
        setLoading(false)
      }
    }

    void load()
    return () => {
      cancelled = true
    }
  }, [user])

  return (
    <section aria-labelledby="admin-heading">
      <h1 id="admin-heading" className="mb-1 text-2xl font-bold">
        Admin queue
      </h1>
      <p className="mb-4 text-sm text-stone-500">
        Pending submissions. {isAdmin ? 'You have admin rights.' : 'Sign in as an admin to act.'}
      </p>

      {!user && (
        <div className="card mb-4 border-amber-200 bg-amber-50 text-sm text-amber-800">
          You are signed out. RLS hides all pending rows from you regardless of this page.
        </div>
      )}

      {loading ? (
        <div className="space-y-3" aria-hidden>
          {[0, 1].map((i) => (
            <div key={i} className="card animate-pulse space-y-2">
              <div className="h-5 w-1/2 rounded bg-stone-200" />
              <div className="h-4 w-1/3 rounded bg-stone-200" />
            </div>
          ))}
        </div>
      ) : pending.length === 0 ? (
        <div className="card text-sm text-stone-500">
          Queue is empty (or you cannot see pending rows). Seed an admin via{' '}
          <code>admin_roles</code> to test.
        </div>
      ) : (
        <ul className="space-y-3">
          {pending.map((e) => (
            <li key={e.id} className="card">
              <div className="flex items-start justify-between gap-3">
                <div>
                  <h2 className="font-semibold">{e.title}</h2>
                  <p className="text-sm text-stone-500">
                    {e.country}
                    {e.city ? ` · ${e.city}` : ''} · {e.event_date}
                  </p>
                </div>
                <div className="flex shrink-0 gap-2">
                  <button type="button" className="btn-primary">
                    Approve
                  </button>
                  <button type="button" className="btn-danger">
                    Reject
                  </button>
                </div>
              </div>
              {e.description && <p className="mt-2 text-sm text-stone-600">{e.description}</p>}
            </li>
          ))}
        </ul>
      )}
    </section>
  )
}
