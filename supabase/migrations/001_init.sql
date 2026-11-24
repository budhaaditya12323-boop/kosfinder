-- Migration: 001_init.sql
-- Description: Inisialisasi tabel kos dan konfigurasi Row Level Security (RLS)

-- 1. Buat tabel kos
CREATE TABLE IF NOT EXISTS public.kos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    gender_type TEXT NOT NULL CHECK (gender_type IN ('putra', 'putri', 'campur')),
    price BIGINT NOT NULL CHECK (price >= 0),
    room_available INTEGER NOT NULL DEFAULT 0 CHECK (room_available >= 0),
    address TEXT NOT NULL,
    contact_number TEXT NOT NULL,
    image_url TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. Index untuk pencarian dan filter cepat
CREATE INDEX IF NOT EXISTS idx_kos_is_active ON public.kos(is_active);
CREATE INDEX IF NOT EXISTS idx_kos_owner_id ON public.kos(owner_id);
CREATE INDEX IF NOT EXISTS idx_kos_gender_type ON public.kos(gender_type);
CREATE INDEX IF NOT EXISTS idx_kos_price ON public.kos(price);

-- 3. Trigger otomatis untuk update timestamp updated_at
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_kos_updated_at ON public.kos;
CREATE TRIGGER set_kos_updated_at
    BEFORE UPDATE ON public.kos
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- 4. Aktifkan Row Level Security (RLS)
ALTER TABLE public.kos ENABLE ROW LEVEL SECURITY;

-- 5. Aturan RLS (Policies)

-- Policy SELECT:
-- Publik / Guest dapat melihat kos aktif (is_active = true)
-- Pemilik kos dapat melihat semua kos miliknya (aktif maupun diarsip / soft-deleted)
CREATE POLICY "Public and owners can view kos"
    ON public.kos
    FOR SELECT
    USING (
        is_active = true
        OR (auth.uid() IS NOT NULL AND auth.uid() = owner_id)
    );

-- Policy INSERT:
-- Hanya pengguna terautentikasi (pemilik) yang dapat menambah kos miliknya sendiri
CREATE POLICY "Authenticated users can insert their own kos"
    ON public.kos
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = owner_id);

-- Policy UPDATE:
-- Hanya pemilik yang dapat mengubah data kos miliknya sendiri (termasuk soft-delete is_active = false)
CREATE POLICY "Owners can update their own kos"
    ON public.kos
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = owner_id)
    WITH CHECK (auth.uid() = owner_id);

-- Policy DELETE:
-- Pembatasan penghapusan permanen hanya oleh pemilik (opsional/cadangan karena aplikasi menggunakan soft delete)
CREATE POLICY "Owners can delete their own kos"
    ON public.kos
    FOR DELETE
    TO authenticated
    USING (auth.uid() = owner_id);
