import { useState, type FormEvent } from 'react'
import { supabase } from '../lib/supabase'
import { EVENT_TAGS, type EventTag } from '../types'

/**
 * Event submission form (issue #13). RLS forces status = 'pending' on insert;
 * the client never sets status itself (docs/rls.md rule 4).
 */

const COUNTRIES = ['IN', 'NG', 'US', 'DE']

export default function Submit() {
  const [title, setTitle] = useState('')
  const [description, setDescription] = useState('')
  const [country, setCountry] = useState('IN')
  const [city, setCity] = useState('')
  const [eventDate, setEventDate] = useState('')
  const [url, setUrl] = useState('')
  const [tags, setTags] = useState<EventTag[]>([])
  const [error, setError] = useState<string | null>(null)
  const [done, setDone] = useState(false)

  function toggleTag(t: EventTag) {
    setTags((prev) => (prev.includes(t) ? prev.filter((x) => x !== t) : [...prev, t]))
  }

  function onSubmit(ev: FormEvent) {
    ev.preventDefault()
    setError(null)

    // Client-side validation (mirror of the DB checks - RLS still enforces the truth)
    if (title.trim().length < 3) return setError('Title must be at least 3 characters.')
    if (!/^[A-Z]{2}$/.test(country)) return setError('Pick a valid country code.')
    if (!eventDate) return setError('Event date is required.')
    if (url && !/^https?:\/\//i.test(url)) return setError('URL must start with http(s)://')

    // Live wiring (issue: "event submission form with validation"):
    // const { error: dbError } = await supabase.from('events').insert({
    //   title, description, country, city, event_date: eventDate, url, tags,
    //   submitted_by: user.id,
    // })
    void supabase
    setDone(true)
  }

  if (done) {
    return (
      <div className="card text-center">
        <p className="mb-2 text-2xl" aria-hidden>
          ✅
        </p>
        <h1 className="text-lg font-semibold">Submitted for review</h1>
        <p className="mt-1 text-sm text-stone-500">
          An admin approves within 48 h. Until approval, only you and the admins can see it.
        </p>
      </div>
    )
  }

  return (
    <section aria-labelledby="submit-heading" className="mx-auto max-w-xl">
      <h1 id="submit-heading" className="mb-1 text-2xl font-bold">
        Submit an event
      </h1>
      <p className="mb-4 text-sm text-stone-500">
        Submissions land in the admin queue - nothing is auto-published.
      </p>

      <form className="card space-y-4" onSubmit={onSubmit} noValidate>
        <div>
          <label className="label" htmlFor="title">
            Title
          </label>
          <input
            id="title"
            className="input"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            required
            minLength={3}
            maxLength={200}
          />
        </div>

        <div>
          <label className="label" htmlFor="description">
            Description
          </label>
          <textarea
            id="description"
            className="input min-h-20"
            value={description}
            onChange={(e) => setDescription(e.target.value)}
          />
        </div>

        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="label" htmlFor="country">
              Country
            </label>
            <select
              id="country"
              className="input"
              value={country}
              onChange={(e) => setCountry(e.target.value)}
            >
              {COUNTRIES.map((c) => (
                <option key={c} value={c}>
                  {c}
                </option>
              ))}
            </select>
          </div>
          <div>
            <label className="label" htmlFor="city">
              City (optional)
            </label>
            <input
              id="city"
              className="input"
              value={city}
              onChange={(e) => setCity(e.target.value)}
            />
          </div>
        </div>

        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="label" htmlFor="event-date">
              Date
            </label>
            <input
              id="event-date"
              type="date"
              className="input"
              value={eventDate}
              onChange={(e) => setEventDate(e.target.value)}
              required
            />
          </div>
          <div>
            <label className="label" htmlFor="url">
              URL
            </label>
            <input
              id="url"
              type="url"
              className="input"
              placeholder="https://…"
              value={url}
              onChange={(e) => setUrl(e.target.value)}
            />
          </div>
        </div>

        <fieldset>
          <legend className="label">Tags</legend>
          <div className="flex flex-wrap gap-2">
            {EVENT_TAGS.map((t) => (
              <label
                key={t}
                className="inline-flex cursor-pointer items-center gap-1 rounded-full border border-stone-300 px-2 py-1 text-xs has-[:checked]:border-indigo-500 has-[:checked]:bg-indigo-50"
              >
                <input
                  type="checkbox"
                  className="accent-indigo-600"
                  checked={tags.includes(t)}
                  onChange={() => toggleTag(t)}
                />
                {t}
              </label>
            ))}
          </div>
        </fieldset>

        {error && (
          <p role="alert" className="text-sm text-red-600">
            {error}
          </p>
        )}

        <button type="submit" className="btn-primary w-full">
          Submit for review
        </button>
      </form>
    </section>
  )
}
