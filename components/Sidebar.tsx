'use client'

import Link from 'next/link'
import { usePathname } from 'next/navigation'
import {
  BarChart2,
  Building2,
  Coffee,
  MapPin,
  TrendingUp,
} from 'lucide-react'

import { cn } from '@/lib/utils'

const navItems = [
  { href: '/map', label: 'Map', icon: MapPin },
  { href: '/time-series', label: 'Time Series', icon: TrendingUp },
  { href: '/compare', label: 'Compare', icon: BarChart2 },
  { href: '/competitors', label: 'Competitors', icon: Building2 },
  { href: '/own-store', label: 'Own Store', icon: Coffee },
] as const

export function Sidebar() {
  const pathname = usePathname()

  return (
    <aside className="flex h-full w-56 flex-col border-r border-zinc-200 bg-white">
      <div className="flex h-14 items-center border-b border-zinc-200 px-5">
        <span className="text-sm font-semibold tracking-tight text-zinc-900">
          Knowledge Goose
        </span>
      </div>

      <nav className="flex flex-1 flex-col gap-1 p-3">
        {navItems.map(({ href, label, icon: Icon }) => {
          const isActive = pathname === href || pathname.startsWith(href + '/')
          return (
            <Link
              key={href}
              href={href}
              className={cn(
                'flex items-center gap-3 rounded-md px-3 py-2 text-sm font-medium transition-colors',
                isActive
                  ? 'bg-zinc-100 text-zinc-900'
                  : 'text-zinc-500 hover:bg-zinc-50 hover:text-zinc-900',
              )}
            >
              <Icon className="h-4 w-4 shrink-0" />
              {label}
            </Link>
          )
        })}
      </nav>
    </aside>
  )
}
