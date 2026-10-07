import { BrowserRouter, Link, Navigate, Route, Routes } from 'react-router-dom'
import { AuthProvider, useAuth } from './auth/AuthContext'
import Feed from './pages/Feed'
import Submit from './pages/Submit'
import Admin from './pages/Admin'
import NotFound from './pages/NotFound'

function Header() {
  const { user } = useAuth()

  return (
    <header className="border-b border-stone-200 bg-white">
      <div className="mx-auto flex max-w-4xl items-center justify-between gap-4 px-4 py-3">
        <Link to="/" className="text-lg font-bold text-indigo-700">
          DevBridge 🔗
        </Link>
        <nav className="flex items-center gap-4 text-sm" aria-label="Main">
          <Link to="/" className="hover:text-indigo-700">
            Feed
          </Link>
          <Link to="/submit" className="hover:text-indigo-700">
            Submit event
          </Link>
          <Link to="/admin" className="hover:text-indigo-700">
            Admin
          </Link>
          {user ? (
            <span className="text-stone-500" title={user.email}>
              Signed in
            </span>
          ) : (
            <span className="text-stone-500">Guest</span>
          )}
        </nav>
      </div>
    </header>
  )
}

function Footer() {
  return (
    <footer className="border-t border-stone-200 bg-white">
      <div className="mx-auto max-w-4xl px-4 py-4 text-xs text-stone-500">
        SWOC&apos;26 walking skeleton - scope frozen to the MVP. Docs live in{' '}
        <code>docs/</code>; the issue list is the plan.
      </div>
    </footer>
  )
}

function Shell() {
  return (
    <div className="flex min-h-screen flex-col">
      <Header />
      <main className="mx-auto w-full max-w-4xl flex-1 px-4 py-6">
        <Routes>
          <Route path="/" element={<Feed />} />
          <Route path="/submit" element={<Submit />} />
          <Route path="/admin" element={<Admin />} />
          <Route path="/404" element={<NotFound />} />
          <Route path="*" element={<Navigate to="/404" replace />} />
        </Routes>
      </main>
      <Footer />
    </div>
  )
}

export default function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Shell />
      </BrowserRouter>
    </AuthProvider>
  )
}
