"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { useAuth } from "@/lib/auth";

/** Destinations differ by role: companies scout, interns get scouted. */
function navLinksFor(role: "intern" | "company" | undefined) {
  if (role === "company") {
    return [
      { href: "/interns", label: "インターン生を探す" },
      { href: "/company/jobs", label: "募集管理" },
      { href: "/messages", label: "メッセージ" },
    ];
  }
  if (role === "intern") {
    return [
      { href: "/jobs", label: "募集を見る" },
      { href: "/messages", label: "メッセージ" },
    ];
  }
  return [{ href: "/jobs", label: "募集を見る" }];
}

export function AppHeader() {
  const { account, logout, loading } = useAuth();
  const pathname = usePathname();
  const router = useRouter();

  const links = navLinksFor(account?.role);

  function onLogout() {
    logout();
    router.push("/");
  }

  return (
    <header className="bg-ai-900 text-white">
      <div className="mx-auto flex max-w-5xl flex-wrap items-center gap-x-6 gap-y-2 px-4 py-3">
        <Link href="/" className="text-lg font-semibold tracking-tight">
          Scout
        </Link>

        <nav className="flex items-center gap-1 text-sm">
          {links.map((link) => {
            // Treat nested routes (/messages/3) as the parent being active.
            const active =
              pathname === link.href || pathname.startsWith(`${link.href}/`);
            return (
              <Link
                key={link.href}
                href={link.href}
                aria-current={active ? "page" : undefined}
                className={`rounded px-2.5 py-1.5 transition-colors ${
                  active
                    ? "bg-white/15 text-white"
                    : "text-white/70 hover:bg-white/10 hover:text-white"
                }`}
              >
                {link.label}
              </Link>
            );
          })}
        </nav>

        <div className="ml-auto flex items-center gap-3 text-sm">
          {loading ? null : account ? (
            <>
              <span className="hidden text-white/70 sm:inline">
                {account.email}
              </span>
              <button
                onClick={onLogout}
                className="rounded px-2.5 py-1.5 text-white/70 transition-colors hover:bg-white/10 hover:text-white"
              >
                ログアウト
              </button>
            </>
          ) : (
            <>
              <Link
                href="/login"
                className="rounded px-2.5 py-1.5 text-white/70 transition-colors hover:bg-white/10 hover:text-white"
              >
                ログイン
              </Link>
              <Link
                href="/register"
                className="rounded bg-white px-3 py-1.5 font-medium text-ai-900 transition-colors hover:bg-white/90"
              >
                登録
              </Link>
            </>
          )}
        </div>
      </div>
    </header>
  );
}
