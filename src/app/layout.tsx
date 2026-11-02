import type { Metadata } from "next";
import "./globals.css";
import Header from "@/components/Header";
import Footer from "@/components/Footer";

export const metadata: Metadata = {
  metadataBase: new URL(process.env.NEXT_PUBLIC_SITE_URL || "https://inzoziacademy.rw"),
  title: { default: "Inzozi Academy | Nurturing Big Dreams", template: "%s | Inzozi Academy" },
  description: "A Christ-centered preschool and primary school in Karama, Kigali. Discover a caring community where every child can learn and thrive.",
  openGraph: { title: "Inzozi Academy", description: "Nurturing big dreams, shaping bright futures.", type: "website", locale: "en_RW" },
};
export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="en"><body><Header />{children}<Footer /></body></html>;
}
