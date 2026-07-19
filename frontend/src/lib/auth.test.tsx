import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen, waitFor, act } from "@testing-library/react";
import { AuthProvider, useAuth } from "./auth";

function Probe() {
  const { account, login } = useAuth();
  return (
    <div>
      <span data-testid="email">{account?.email ?? "none"}</span>
      <button onClick={() => login("a@example.com", "password123")}>login</button>
    </div>
  );
}

beforeEach(() => localStorage.clear());

describe("AuthProvider", () => {
  it("ログインで account を保持する", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue(
      new Response(JSON.stringify({ token: "t", account: { id: 1, email: "a@example.com", role: "intern", profile: { id: 1, name: "A" } } }), { status: 200 })
    ));
    render(<AuthProvider><Probe /></AuthProvider>);
    await act(async () => screen.getByText("login").click());
    await waitFor(() => expect(screen.getByTestId("email").textContent).toBe("a@example.com"));
    expect(localStorage.getItem("scout_token")).toBe("t");
  });
});
