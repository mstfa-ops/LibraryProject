-- 1. VERİTABANI OLUŞTURMA
CREATE DATABASE KutuphaneDB;
GO
USE KutuphaneDB;
GO

-- 2. TABLOLAR (DDL ve Veri Bütünlüğü - PRIMARY/FOREIGN KEY, NOT NULL, UNIQUE)
CREATE TABLE Roller (
    RolID INT IDENTITY(1,1) PRIMARY KEY,
    RolAdi VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Kullanicilar (
    KullaniciID INT IDENTITY(1,1) PRIMARY KEY,
    AdSoyad VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Sifre VARCHAR(255) NOT NULL,
    RolID INT FOREIGN KEY REFERENCES Roller(RolID)
);

CREATE TABLE Kategoriler (
    KategoriID INT IDENTITY(1,1) PRIMARY KEY,
    KategoriAdi VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Kitaplar (
    KitapID INT IDENTITY(1,1) PRIMARY KEY,
    KitapAdi VARCHAR(150) NOT NULL,
    Yazar VARCHAR(100) NOT NULL,
    KategoriID INT FOREIGN KEY REFERENCES Kategoriler(KategoriID),
    StokAdedi INT NOT NULL CHECK (StokAdedi >= 0) -- Veri Bütünlüğü CHECK operatörü
);

CREATE TABLE OduncIslemleri (
    IslemID INT IDENTITY(1,1) PRIMARY KEY,
    KullaniciID INT FOREIGN KEY REFERENCES Kullanicilar(KullaniciID),
    KitapID INT FOREIGN KEY REFERENCES Kitaplar(KitapID),
    AlisTarihi DATE DEFAULT GETDATE(),
    IadeTarihi DATE NULL
);

-- 3. CRUD (Örnek Veri Ekleme - INSERT)
INSERT INTO Roller (RolAdi) VALUES ('Admin'), ('Ogrenci');
INSERT INTO Kategoriler (KategoriAdi) VALUES ('Bilim Kurgu'), ('Tarih'), ('Yazılım');
INSERT INTO Kullanicilar (AdSoyad, Email, Sifre, RolID) VALUES 
('Ahmet Yilmaz', 'admin@kutuphane.com', '1234', 1),
('Ayşe Kaya', 'ayse@ogrenci.com', '1234', 2);
INSERT INTO Kitaplar (KitapAdi, Yazar, KategoriID, StokAdedi) VALUES 
('C# Programlama', 'Ali Veli', 3, 5),
('Zaman Makinesi', 'H.G. Wells', 1, 2);

-- 4. FONKSİYON (Geciken Gün Sayısını Hesaplama)
GO
CREATE FUNCTION dbo.fn_GecikenGunSayisi(@AlisTarihi DATE)
RETURNS INT
AS
BEGIN
    DECLARE @GecikenGun INT;
    SET @GecikenGun = DATEDIFF(DAY, @AlisTarihi, GETDATE()) - 15; -- 15 gün yasal süre
    IF @GecikenGun < 0 SET @GecikenGun = 0;
    RETURN @GecikenGun;
END;
GO

-- 5. STORED PROCEDURE (Kitap Ödünç Alma - İşlem bazlı yönetim)
CREATE PROCEDURE sp_KitapOduncAl
    @KullaniciID INT,
    @KitapID INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Kitaplar WHERE KitapID = @KitapID AND StokAdedi > 0)
    BEGIN
        INSERT INTO OduncIslemleri (KullaniciID, KitapID, AlisTarihi)
        VALUES (@KullaniciID, @KitapID, GETDATE());
        
        UPDATE Kitaplar SET StokAdedi = StokAdedi - 1 WHERE KitapID = @KitapID;
        PRINT 'Kitap başarıyla ödünç alındı.';
    END
    ELSE
    BEGIN
        PRINT 'Hata: Yeterli stok yok.';
    END
END;
GO

-- 6. TRIGGER (Kitap İade Edildiğinde Stoku Artırma)
CREATE TRIGGER trg_KitapIade
ON OduncIslemleri
AFTER UPDATE
AS
BEGIN
    IF UPDATE(IadeTarihi)
    BEGIN
        DECLARE @KitapID INT;
        SELECT @KitapID = KitapID FROM inserted WHERE IadeTarihi IS NOT NULL;
        
        IF @KitapID IS NOT NULL
        BEGIN
            UPDATE Kitaplar SET StokAdedi = StokAdedi + 1 WHERE KitapID = @KitapID;
        END
    END
END;
GO

-- 7. GELİŞMİŞ SORGULAMA (Arama, Filtreleme, JOIN, GROUP BY, HAVING)
-- En çok ödünç alınan kategorileri listeleyen sorgu
SELECT k.KategoriAdi, COUNT(o.IslemID) AS ToplamIslem
FROM Kategoriler k
JOIN Kitaplar kit ON k.KategoriID = kit.KategoriID
JOIN OduncIslemleri o ON kit.KitapID = o.KitapID
GROUP BY k.KategoriAdi
HAVING COUNT(o.IslemID) > 0;
-- Örnek işlem
-- Kitabın stoğunu kontrol ediyoruz
SELECT KitapAdi, StokAdedi FROM Kitaplar WHERE KitapID = 1;

-- Ödünç işlemlerinde kayıt var mı bakıyoruz
SELECT * FROM OduncIslemleri;