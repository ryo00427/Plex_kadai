import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import CompanyJobsPage from "./page";

const job = {
  id: 1,
  title: "フロントエンド募集",
  status: "published" as const,
  location: "東京",
  employment_type: "インターン",
  company: { id: 7, name: "サンプル社" },
};

vi.mock("@/lib/auth", () => ({ useAuth: () => ({ token: "t" }) }));
vi.mock("@/lib/hooks", () => ({
  useApi: () => ({ data: { job_postings: [job] }, error: null, loading: false }),
}));
const apiFetchMock = vi.fn().mockResolvedValue(undefined);
vi.mock("@/lib/api", () => ({ apiFetch: (...args: unknown[]) => apiFetchMock(...args) }));

describe("CompanyJobsPage", () => {
  beforeEach(() => apiFetchMock.mockClear());

  it("確認ダイアログをキャンセルすると削除しない", () => {
    vi.spyOn(window, "confirm").mockReturnValue(false);
    render(<CompanyJobsPage />);

    fireEvent.click(screen.getByRole("button", { name: "削除" }));

    expect(apiFetchMock).not.toHaveBeenCalled();
    expect(screen.getByText("フロントエンド募集")).toBeDefined();
  });

  it("確認すると DELETE を送り行を取り除く", async () => {
    vi.spyOn(window, "confirm").mockReturnValue(true);
    render(<CompanyJobsPage />);

    fireEvent.click(screen.getByRole("button", { name: "削除" }));

    await waitFor(() =>
      expect(apiFetchMock).toHaveBeenCalledWith("/job_postings/1", {
        method: "DELETE",
        token: "t",
      })
    );
    await waitFor(() => expect(screen.queryByText("フロントエンド募集")).toBeNull());
  });
});
