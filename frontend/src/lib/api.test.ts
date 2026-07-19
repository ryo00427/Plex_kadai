import { describe, it, expect, vi, afterEach } from "vitest";
import { apiFetch, ApiError } from "./api";

afterEach(() => vi.restoreAllMocks());

describe("apiFetch", () => {
  it("成功レスポンスを JSON で返す", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue(
      new Response(JSON.stringify({ ok: true }), { status: 200 })
    ));
    const res = await apiFetch<{ ok: boolean }>("/ping");
    expect(res.ok).toBe(true);
  });

  it("token があれば Authorization を付ける", async () => {
    const fetchMock = vi.fn().mockResolvedValue(new Response("{}", { status: 200 }));
    vi.stubGlobal("fetch", fetchMock);
    await apiFetch("/me", { token: "abc" });
    const headers = (fetchMock.mock.calls[0][1] as RequestInit).headers as Record<string, string>;
    expect(headers.Authorization).toBe("Bearer abc");
  });

  it("非 2xx は ApiError を投げる", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue(
      new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401 })
    ));
    await expect(apiFetch("/me")).rejects.toBeInstanceOf(ApiError);
  });
});
