"use client";

import { useEffect, useState } from "react";
import { apiFetch } from "./api";

export function useApi<T>(path: string, token: string | null, enabled = true) {
  const [data, setData] = useState<T | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!enabled) {
      // Not ready to fetch yet (e.g. still waiting on auth) -- keep the
      // loading state so callers show a spinner instead of a stale error
      // or an empty list.
      setLoading(true);
      return;
    }

    const controller = new AbortController();
    let isMounted = true;

    // Reset error/loading at the start of every fetch so a stale error from
    // a previous (e.g. unauthenticated) request doesn't leak into a
    // subsequent successful render.
    setError(null);
    setLoading(true);

    apiFetch<T>(path, { token, signal: controller.signal })
      .then((res) => {
        if (!isMounted) return;
        setData(res);
      })
      .catch((e) => {
        if (!isMounted) return;
        if (e instanceof Error && e.name === "AbortError") return;
        setError(e instanceof Error ? e.message : String(e));
      })
      .finally(() => {
        if (!isMounted) return;
        setLoading(false);
      });

    return () => {
      isMounted = false;
      controller.abort();
    };
  }, [path, token, enabled]);

  return { data, error, loading };
}
