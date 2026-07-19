import Link from "next/link";
import { RegisterForm } from "@/components/RegisterForm";

export default function RegisterPage() {
  return (
    <div className="mx-auto max-w-sm">
      <h1 className="text-center text-2xl font-semibold tracking-tight">
        アカウント登録
      </h1>
      <div className="card mt-6 p-6">
        <RegisterForm />
      </div>
      <p className="mt-4 text-center text-sm text-muted">
        すでに登録済みの方は{" "}
        <Link href="/login" className="text-ai-700 hover:underline">
          ログイン
        </Link>
      </p>
    </div>
  );
}
