import { createClient } from "@/lib/supabase/server";

const defaults: Record<string, string> = {
  tagline: "Nurturing big dreams, shaping bright futures.",
  introduction: "Inzozi means dreams, and we exist to help every child reach theirs. We are a Christ-centered preschool and primary school committed to nurturing each child’s academic, spiritual, physical, social and emotional growth.",
  philosophy: "Children learn best when they feel known, safe and curious. We combine Rwanda’s national curriculum with hands-on, student-centered learning inspired by Montessori principles.",
  mission: "To nurture the whole child through high-quality learning, faith, care and character.",
  vision: "A future where every child is equipped and inspired to reach their dreams.",
  years_serving: "4 years", preschool_ratio: "10 : 1", primary_ratio: "15 : 1", enrollment_levels: "N1 – P6",
  address: "Karama (Kanombe), Kicukiro, Kigali, Rwanda", phone: "+250 793 766 053", email: "info@inzoziacademy.rw",
  faith_identity: "We are a Christ-centered community that nurtures faith and character while warmly welcoming families of all backgrounds.",
  promise_1_title:"Small classes",promise_1_copy:"A 10:1 preschool and 15:1 primary student–teacher ratio helps every child get the attention they need.",
  promise_2_title:"Whole-child care",promise_2_copy:"Academic, spiritual, physical, social and emotional growth, grounded in faith and character.",
  promise_3_title:"Literacy first",promise_3_copy:"Strong reading and language skills lay the foundation for a lifetime of learning.",
  promise_4_title:"Always growing",promise_4_copy:"We keep building our facilities and investing in the people who make school special.",
  promise_1_image:"/images/small-classes.jpg",promise_2_image:"/images/christ-centered.jpg",promise_3_image:"/images/literacy-first.jpg",promise_4_image:"/images/building-the-future.jpg",
  intro_image:"/images/classroom-learning.webp",
  hero_image_url:"/images/school-classroom-hero.jpg",
};
export async function getSettings() {
  const supabase = await createClient();
  if (!supabase) return defaults;
  const { data } = await supabase.from("website_settings").select("key,value").eq("is_public", true);
  return { ...defaults, ...(data || []).reduce((a: any, r: any) => ({ ...a, [r.key]: r.value }), {}) };
}
