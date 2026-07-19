import { describe, it, expect, vi, afterEach } from "vitest";
import { renderHook, waitFor } from "@testing-library/react";
import { useApi } from "./hooks";
import { apiFetch } from "./api";

vi.mock("./api", () => ({ apiFetch: vi.fn() }));

afterEach(() => vi.restoreAllMocks());

describe("useApi", () => {
  it("前回のリクエストが失敗しても、token が用意されて成功したら error がリセットされる", async () => {
    // Regression test for the reload race: the first fetch fires before the
    // token is ready and fails (e.g. 401 Unauthorized), then the token
    // becomes available and the second fetch succeeds. `error` must not
    // leak from the first (stale) attempt into the successful render.
    const fetchMock = apiFetch as unknown as ReturnType<typeof vi.fn>;
    fetchMock
      .mockRejectedValueOnce(new Error("Unauthorized"))
      .mockResolvedValueOnce({ ok: true });

    const { result, rerender } = renderHook(
      ({ token }) => useApi<{ ok: boolean }>("/ping", token),
      { initialProps: { token: null as string | null } }
    );

    await waitFor(() => expect(result.current.error).toBe("Unauthorized"));

    rerender({ token: "abc" });

    await waitFor(() => expect(result.current.data).toEqual({ ok: true }));
    expect(result.current.error).toBeNull();
    expect(result.current.loading).toBe(false);
  });
});
