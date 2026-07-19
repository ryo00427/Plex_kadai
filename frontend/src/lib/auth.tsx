"use client";

import { createContext, useContext, useEffect, useState, ReactNode } from "react";
import { apiFetch } from "./api";
import type { Account, Role } from "@/types";

interface RegisterPayload {
  role: Role;
  email: string;
  password: string;
  profile: Record<string, unknown>;
}

interface AuthValue {
  account: Account | null;
  token: string | null;
  loading: boolean;
  login: (email: string, password: string) => Promise<void>;
  register: (payload: RegisterPayload) => Promise<void>;
  logout: () => void;
}

const AuthContext = createContext<AuthValue | null>(null);
const TOKEN_KEY = "scout_token";

export function AuthProvider({ children }: { children: ReactNode }) {
  const [account, setAccount] = useState<Account | null>(null);
  const [token, setToken] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const saved = localStorage.getItem(TOKEN_KEY);
    if (!saved) return setLoading(false);
    setToken(saved);
    apiFetch<{ account: Account }>("/me", { token: saved })
      .then((res) => setAccount(res.account))
      .catch(() => localStorage.removeItem(TOKEN_KEY))
      .finally(() => setLoading(false));
  }, []);

  function persist(res: { token: string; account: Account }) {
    localStorage.setItem(TOKEN_KEY, res.token);
    setToken(res.token);
    setAccount(res.account);
  }

  async function login(email: string, password: string) {
    persist(await apiFetch("/auth/login", { method: "POST", body: { email, password } }));
  }

  async function register(payload: RegisterPayload) {
    persist(await apiFetch("/auth/register", { method: "POST", body: payload }));
  }

  function logout() {
    localStorage.removeItem(TOKEN_KEY);
    setToken(null);
    setAccount(null);
  }

  return (
    <AuthContext.Provider value={{ account, token, loading, login, register, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth must be used within AuthProvider");
  return ctx;
}
