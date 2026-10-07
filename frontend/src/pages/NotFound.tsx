import { Link } from 'react-router-dom'

export default function NotFound() {
  return (
    <div className="card mx-auto max-w-md text-center">
      <p className="mb-2 text-4xl" aria-hidden>
        🧭
      </p>
      <h1 className="text-xl font-bold">404 - page not found</h1>
      <p className="mt-1 mb-4 text-sm text-stone-500">
        That bridge does not exist. Head back to the feed.
      </p>
      <Link to="/" className="btn-primary">
        Back to feed
      </Link>
    </div>
  )
}
