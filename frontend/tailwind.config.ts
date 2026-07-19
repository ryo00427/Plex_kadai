import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        // 藍 (indigo) — institutional / primary
        ai: {
          900: "#16243F",
          700: "#24406E",
          500: "#3B62A8",
          100: "#E4EAF5",
          50: "#F0F4FB",
        },
        // 若葉 — growth, active, scout actions
        wakaba: {
          600: "#33774A",
          500: "#3F8F5B",
          100: "#E2F0E7",
        },
        // 朱 — drafts, destructive
        shu: {
          600: "#A83F2D",
          500: "#C8503C",
          100: "#F8E7E3",
        },
        ground: "#F2F4F7",
        surface: "#FFFFFF",
        ink: "#1A2333",
        muted: "#5B6779",
        line: "#DFE4EC",
      },
      fontFamily: {
        sans: [
          "var(--font-geist-sans)",
          "Hiragino Kaku Gothic ProN",
          "Hiragino Sans",
          "Noto Sans JP",
          "Yu Gothic Medium",
          "Meiryo",
          "sans-serif",
        ],
        mono: ["var(--font-geist-mono)", "ui-monospace", "monospace"],
      },
      boxShadow: {
        card: "0 1px 2px rgba(22, 36, 63, 0.04), 0 2px 8px rgba(22, 36, 63, 0.04)",
        lift: "0 2px 4px rgba(22, 36, 63, 0.06), 0 8px 20px rgba(22, 36, 63, 0.08)",
      },
    },
  },
  plugins: [],
};
export default config;
