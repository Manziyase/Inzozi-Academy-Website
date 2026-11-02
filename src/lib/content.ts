import { createClient } from "@/lib/supabase/server";

export type Row = Record<string, any>;
export async function getPublished(table: string, limit = 6): Promise<Row[]> {
  const supabase = await createClient();
  if (!supabase) return [];
  let query = supabase.from(table).select("*").eq("status", "published");
  if (["articles","gallery_albums"].includes(table)) query=query.order("published_at", { ascending: false, nullsFirst: false });
  else if (table==="testimonials") query=query.order("created_at",{ascending:false});
  else if (table==="events") query=query.order("event_date",{ascending:true,nullsFirst:false});
  else if (["staff_members","academic_programmes","faqs","navigation_items"].includes(table)) query=query.order("display_order",{ascending:true});
  const { data, error } = await query.limit(limit);
  if (error) return [];
  return data || [];
}
