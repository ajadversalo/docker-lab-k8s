import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Web1",
  description: "Next.js frontend for the Docker lab",
  icons: { icon: "/favicon.svg" },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
