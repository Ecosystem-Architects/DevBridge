/** Shared types - mirror of the Supabase schema in supabase/migrations/0001_init.sql. */

export type EventStatus = 'draft' | 'pending' | 'approved' | 'rejected' | 'duplicate'

export const EVENT_TAGS = [
  'online',
  'in-person',
  'hackathon',
  'conference',
  'scholarship',
  'job',
  'cfp',
] as const

export type EventTag = (typeof EVENT_TAGS)[number]

export interface EventRow {
  id: string
  title: string
  description: string | null
  country: string
  city: string | null
  event_date: string
  url: string | null
  tags: string[]
  status: EventStatus
  submitted_by: string
  approved_by: string | null
  submitted_at: string
  decided_at: string | null
}
