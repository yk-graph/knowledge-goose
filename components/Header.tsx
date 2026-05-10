'use client'

import Image from 'next/image'
import { useRouter } from 'next/navigation'
import { LogOut } from 'lucide-react'

import { signOut } from '@/lib/auth-client'
import { cn } from '@/lib/utils'

interface HeaderProps {
  userName: string
  userImage: string | null
  userRole: 'admin' | 'staff'
}

export function Header({ userName, userImage, userRole }: HeaderProps) {
  const router = useRouter()

  async function handleSignOut() {
    await signOut()
    router.push('/login')
    router.refresh()
  }

  const initials = userName
    .split(' ')
    .map((n) => n[0])
    .join('')
    .toUpperCase()
    .slice(0, 2)

  return (
    <header className="flex h-14 items-center justify-end gap-3 border-b border-zinc-200 bg-white px-5">
      <span
        className={cn(
          'inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium',
          userRole === 'admin'
            ? 'bg-violet-100 text-violet-700'
            : 'bg-zinc-100 text-zinc-600',
        )}
      >
        {userRole}
      </span>

      <div className="flex items-center gap-2">
        {userImage ? (
          <Image
            src={userImage}
            alt={userName}
            width={28}
            height={28}
            className="h-7 w-7 rounded-full object-cover"
          />
        ) : (
          <div className="flex h-7 w-7 items-center justify-center rounded-full bg-zinc-200 text-xs font-medium text-zinc-600">
            {initials}
          </div>
        )}
        <span className="text-sm text-zinc-700">{userName}</span>
      </div>

      <button
        onClick={handleSignOut}
        className="flex items-center gap-1.5 rounded-md px-2 py-1.5 text-sm text-zinc-500 transition-colors hover:bg-zinc-100 hover:text-zinc-900"
        aria-label="Sign out"
      >
        <LogOut className="h-4 w-4" />
        <span>Sign out</span>
      </button>
    </header>
  )
}
