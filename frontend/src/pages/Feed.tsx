import { useEffect, useState } from 'react'
import { supabase } from '../lib/supabase'
import { EVENT_TAGS, type EventRow } from '../types'

/**
 * Country feed - the product core (issue #20).
 * Query shape per docs/api.md; RLS guarantees only approved rows for guests.
 */

const COUNTRIES = [
  { code: 'IN', label: '🇮🇳 India' },
  { code: 'NG', label: '🇳🇬 Nigeria' },
  { code: 'US', label: '🇺🇸 United States' },
  { code: 'DE', label: '🇩🇪 Germany' },
]

export default function Feed() {
  const [country, setCountry] = useState('IN')
  const [tag, setTag] = useState<string>('')
  const [events, setEvents] = useState<EventRow[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    let cancelled = false

    async function load() {
      setLoading(true)
      // Live wiring (issue: "implement country-based feed query"):
      // const { data } = await supabase
      //   .from('events')
      //   .select('*')
      //   .eq('status', 'approved')
      //   .eq('country', country)
      //   .order('event_date', { ascending: true })
      void supabase
      if (!cancelled) {
        setEvents([]) // walking skeleton: empty until Supabase credentials are wired
        setLoading(false)
      }
    }

    void load()
    return () => {
      cancelled = true
    }
  }, [country, tag])

  return (
    <section aria-labelledby="feed-heading">
      <h1 id="feed-heading" className="mb-1 text-2xl font-bold">
        Event feed
      </h1>
      <p className="mb-4 text-sm text-stone-500">
        Approved events for your country. Everything here passed the admin queue.
      </p>

      <div className="mb-6 flex flex-wrap items-center gap-2">
        <label className="sr-only" htmlFor="country-filter">
          Country
        </label>
        <select
          id="country-filter"
          className="input max-w-48"
          value={country}
          onChange={(e) => setCountry(e.target.value)}
        >
          {COUNTRIES.map((c) => (
            <option key={c.code} value={c.code}>
              {c.label}
            </option>
          ))}
        </select>

        <label className="sr-only" htmlFor="tag-filter">
          Tag filter
        </label>
        <select
          id="tag-filter"
          className="input max-w-44"
          value={tag}
          onChange={(e) => setTag(e.target.value)}
        >
          <option value="">All kinds</option>
          {EVENT_TAGS.map((t) => (
            <option key={t} value={t}>
              {t}
            </option>
          ))}
        </select>
      </div>

      {loading ? (
        <div className="space-y-3" aria-hidden>
          {[0, 1, 2].map((i) => (
            <div key={i} className="card animate-pulse space-y-2">
              <div className="h-5 w-2/3 rounded bg-stone-200" />
              <div className="h-4 w-1/2 rounded bg-stone-200" />
            </div>
          ))}
        </div>
      ) : events.length === 0 ? (
        <div className="card text-center text-sm text-stone-500">
          <p className="mb-2 text-2xl" aria-hidden>
            🗓️
          </p>
          <p className="font-medium text-stone-700">No approved events here yet.</p>
          <p>
            Be the first:{' '}
            <a className="text-indigo-700 underline" href="/submit">
              submit an event
            </a>{' '}
            for review.
          </p>
        </div>
      ) : (
        <ul className="space-y-3">
          {events.map((e) => (
            <li key={e.id} className="card">
              <div className="flex items-start justify-between gap-3">
                <div>
                  <h2 className="font-semibold">{e.title}</h2>
                  <p className="text-sm text-stone-500">
                    {e.city ? `${e.city}, ` : ''}
                    {e.country} · {e.event_date}
                  </p>
                </div>
                {e.url && (
                  <a className="btn-ghost shrink-0" href={e.url}>
                    Open
                  </a>
                )}
              </div>
              {e.description && <p className="mt-2 text-sm text-stone-600">{e.description}</p>}
              <div className="mt-2 flex flex-wrap gap-1">
                {e.tags.map((t) => (
                  <span key={t} className="tag">
                    {t}
                  </span>
                ))}
              </div>
            </li>
          ))}
        </ul>
      )}
    </section>
  )
}
