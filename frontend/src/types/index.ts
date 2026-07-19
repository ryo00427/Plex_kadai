export type Role = "intern" | "company";

export interface Intern {
  id: number;
  name: string;
  university?: string;
  major?: string;
  graduation_year?: number;
  skills?: string;
  bio?: string;
}

export interface Company {
  id: number;
  name: string;
  industry?: string;
  description?: string;
  website?: string;
}

export interface Account {
  id: number;
  email: string;
  role: Role;
  profile: Intern | Company;
}

export interface JobPosting {
  id: number;
  title: string;
  description?: string;
  requirements?: string;
  location?: string;
  employment_type?: string;
  status: "draft" | "published";
  company: { id: number; name: string };
}

export interface Message {
  id: number;
  body: string;
  sender_type: "Intern" | "Company";
  sender_id: number;
  read_at: string | null;
  created_at: string;
}

export interface Conversation {
  id: number;
  company: { id: number; name: string };
  intern: { id: number; name: string };
  last_message: Message | null;
}
