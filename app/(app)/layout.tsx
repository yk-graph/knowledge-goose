import { headers } from 'next/headers'
import { redirect } from 'next/navigation'

import { auth } from '@/lib/auth'
import { Header } from '@/components/Header'
import { Sidebar } from '@/components/Sidebar'

type AppSession = typeof auth.$Infer.Session

export default async function AppLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const session = (await auth.api.getSession({
    headers: await headers(),
  })) as AppSession | null

  if (!session) {
    redirect('/login')
  }

  const { user } = session
  const userRole: 'admin' | 'staff' = user.role === 'admin' ? 'admin' : 'staff'

  return (
    <div className="flex h-screen overflow-hidden">
      <Sidebar />
      <div className="flex flex-1 flex-col overflow-hidden">
        <Header
          userName={user.name}
          userImage={user.image ?? null}
          userRole={userRole}
        />
        <main className="flex-1 overflow-y-auto bg-zinc-50 p-6">
          {children}
        </main>
      </div>
    </div>
  )
}
