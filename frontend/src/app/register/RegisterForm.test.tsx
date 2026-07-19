import { describe, it, expect, vi } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import { RegisterForm } from "@/components/RegisterForm";

vi.mock("next/navigation", () => ({ useRouter: () => ({ push: vi.fn() }) }));
const registerMock = vi.fn().mockResolvedValue(undefined);
vi.mock("@/lib/auth", () => ({ useAuth: () => ({ register: registerMock }) }));

describe("RegisterForm", () => {
  it("company を選ぶと会社名フィールドが出る", () => {
    render(<RegisterForm />);
    fireEvent.change(screen.getByLabelText("ロール"), { target: { value: "company" } });
    expect(screen.getByLabelText("会社名")).toBeDefined();
  });
});
