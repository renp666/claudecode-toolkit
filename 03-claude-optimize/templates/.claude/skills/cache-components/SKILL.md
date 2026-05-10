---
name: cache-components
description: |
  Expert guidance for Next.js Cache Components and Partial Prerendering (PPR).
  **PROACTIVE ACTIVATION**: Use this skill automatically when working in Next.js projects that have `cacheComponents: true` in their next.config.ts/next.config.js.
  **USE CASES**: Implementing 'use cache' directive, configuring cache lifetimes with cacheLife(), tagging cached data with cacheTag(), invalidating caches with updateTag()/revalidateTag(), optimizing static vs dynamic content boundaries, debugging cache issues.
---

# Next.js Cache Components

Source: https://github.com/vercel/next.js (Vercel 官方)

> **Auto-activation**: This skill activates automatically in projects with `cacheComponents: true` in next.config.

## Core Concept

Cache Components enable **Partial Prerendering (PPR)** - mixing static HTML shells with dynamic streaming content for optimal performance.

```
┌─────────────────────────────────────────────────────┐
│                   Static Shell                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │
│  │   Header    │  │  Cached     │  │  Suspense   │  │
│  │  (static)   │  │  Content    │  │  Fallback   │  │
│  └─────────────┘  └─────────────┘  └──────┬──────┘  │
│                                    ┌──────▼──────┐  │
│                                    │  Dynamic    │  │
│                                    │  (streams)  │  │
│                                    └─────────────┘  │
└─────────────────────────────────────────────────────┘
```

## Mental Model: The Caching Decision Tree

```
Does this component fetch data or perform I/O?
├─ NO → Pure component, no action needed
└─ YES
   ├─ Does it depend on request context? (cookies, headers, searchParams)
   │  └─ YES → Wrap in <Suspense> (dynamic streaming)
   └─ NO
      ├─ Can this be cached? (same for all users?)
      │  └─ YES → 'use cache' + cacheTag() + cacheLife()
      └─ NO → Wrap in <Suspense>
```

## Quick Start

```typescript
// next.config.ts
import type { NextConfig } from 'next'
const nextConfig: NextConfig = {
  cacheComponents: true,
}
export default nextConfig
```

### Basic Usage

```tsx
async function CachedPosts() {
  'use cache'
  const posts = await db.posts.findMany()
  return <PostList posts={posts} />
}

export default async function BlogPage() {
  return (
    <>
      <Header />                          {/* Static */}
      <CachedPosts />                     {/* Cached */}
      <Suspense fallback={<Skeleton />}>
        <DynamicComments />               {/* Dynamic - streams */}
      </Suspense>
    </>
  )
}
```

## Core APIs

### 1. `'use cache'` Directive

Marks code as cacheable. Can be applied at three levels:

```tsx
// File-level: All exports are cached
'use cache'
export async function getData() { /* ... */ }

// Component-level
async function UserCard({ id }: { id: string }) {
  'use cache'
  const user = await fetchUser(id)
  return <Card>{user.name}</Card>
}

// Function-level
async function fetchWithCache(url: string) {
  'use cache'
  return fetch(url).then((r) => r.json())
}
```

**Important**: All cached functions must be `async`.

### 2. `cacheLife()` - Control Cache Duration

```tsx
import { cacheLife } from 'next/cache'

async function Posts() {
  'use cache'
  cacheLife('hours')  // Predefined: 'default', 'seconds', 'minutes', 'hours', 'days', 'weeks', 'max'

  // Or custom:
  cacheLife({
    stale: 60,        // 1 min - client cache validity
    revalidate: 3600, // 1 hr - start background refresh
    expire: 86400,    // 1 day - absolute expiration
  })

  return await db.posts.findMany()
}
```

### 3. `cacheTag()` - Tag for Invalidation

```tsx
import { cacheTag } from 'next/cache'

async function UserProfile({ userId }: { id: string }) {
  'use cache'
  cacheTag('users', `user-${userId}`)
  return await db.users.findUnique({ where: { id: userId } })
}
```

### 4. `updateTag()` - Immediate Invalidation (read-your-own-writes)

```tsx
'use server'
import { updateTag } from 'next/cache'

export async function createPost(formData: FormData) {
  await db.posts.create({ data: formData })
  updateTag('posts')  // Client immediately sees fresh data
}
```

### 5. `revalidateTag()` - Background Revalidation (stale-while-revalidate)

```tsx
'use server'
import { revalidateTag } from 'next/cache'

export async function updatePost(id: string, data: FormData) {
  await db.posts.update({ where: { id }, data })
  revalidateTag('posts', 'max')  // Serve stale, refresh in background
}
```

## Code Generation Guidelines

1. **Always use `async`** - All cached functions must be async
2. **Place `'use cache'` first** - Must be first statement in function body
3. **Call `cacheLife()` early** - Should follow `'use cache'` directive
4. **Tag meaningfully** - Use semantic tags that match your invalidation needs
5. **Extract runtime data** - Move `cookies()`/`headers()` outside cached scope
6. **Wrap dynamic content** - Use `<Suspense>` for non-cached async components

## Review Checklist

- [ ] Data fetching without `'use cache'` where caching would benefit
- [ ] Missing `cacheTag()` calls (makes invalidation impossible)
- [ ] Missing `cacheLife()` (relies on defaults)
- [ ] Server Actions without `updateTag()`/`revalidateTag()` after mutations
- [ ] `cookies()`/`headers()` called inside `'use cache'` scope
- [ ] Dynamic components without `<Suspense>` boundaries
- [ ] **DEPRECATED**: `export const revalidate` - replace with `cacheLife()`
- [ ] **DEPRECATED**: `export const dynamic` - replace with Suspense + cache boundaries
- [ ] Empty `generateStaticParams()` return - must provide at least one param
