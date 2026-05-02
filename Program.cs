using System;
using System.Data;
using System.Data.SqlClient;

namespace KutuphaneUygulamasi
{
    // Veritabanı İşlemlerini Yapan Sınıfımız
    public class VeritabaniBaglantisi
    {
        // DİKKAT: SSMS Sunucu adınızı 'localhost' veya kendi sunucu adınızla değiştirin.
        string connectionString = "Server=(localdb)\\MSSQLLocalDB;Database=KutuphaneDB;Integrated Security=True;";

        public bool GirisYap(string email, string sifre)
        {
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                string query = "SELECT RolID FROM Kullanicilar WHERE Email=@email AND Sifre=@sifre";
                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@email", email);
                cmd.Parameters.AddWithValue("@sifre", sifre);

                try
                {
                    con.Open();
                    object result = cmd.ExecuteScalar();

                    if (result != null)
                    {
                        int rolID = Convert.ToInt32(result);
                        Console.WriteLine(rolID == 1 ? "[BAŞARILI] Admin girişi yapıldı." : "[BAŞARILI] Öğrenci girişi yapıldı.");
                        return true;
                    }
                    else
                    {
                        Console.WriteLine("[HATA] Hatalı email veya şifre girdiniz.");
                        return false;
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine("[HATA] Veritabanı bağlantı hatası: " + ex.Message);
                    return false;
                }
            }
        }

        public void KitapOduncAl(int kullaniciId, int kitapId)
        {
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                SqlCommand cmd = new SqlCommand("sp_KitapOduncAl", con);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@KullaniciID", kullaniciId);
                cmd.Parameters.AddWithValue("@KitapID", kitapId);

                try
                {
                    con.Open();
                    cmd.ExecuteNonQuery();
                    Console.WriteLine("[BAŞARILI] sp_KitapOduncAl prosedürü çalıştı. İşlem tamamlandı.");
                }
                catch (Exception ex)
                {
                    Console.WriteLine("[HATA] İşlem sırasında bir sorun oluştu: " + ex.Message);
                }
            }
        }
    }

    // PROGRAMIN ÇALIŞMAYA BAŞLADIĞI ANA METOT (MAIN)
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("==================================================");
            Console.WriteLine("    KÜTÜPHANE YÖNETİM SİSTEMİNE HOŞ GELDİNİZ      ");
            Console.WriteLine("==================================================\n");

            // Bağlantı sınıfımızdan bir nesne (object) üretiyoruz
            VeritabaniBaglantisi vt = new VeritabaniBaglantisi();

            // 1. SENARYO: Sistem Girişi (SSMS kodlarında eklediğimiz Admin verisiyle test ediyoruz)
            Console.WriteLine(">>> Sisteme giriş deneniyor...");
            bool girisBasarili = vt.GirisYap("admin@kutuphane.com", "1234");

            Console.WriteLine(); // Boşluk

            // 2. SENARYO: Eğer giriş başarılıysa kitap ödünç alma işlemini tetikle
            if (girisBasarili)
            {
                Console.WriteLine(">>> Kitap ödünç alma işlemi başlatılıyor...");

                // KullaniciID = 1 (Ahmet Yılmaz)
                // KitapID = 1 (C# Programlama) 
                // Bu değerleri SSMS'de INSERT ile tablomuza eklemiştik.
                vt.KitapOduncAl(1, 1);
            }
            // ... (önceki kodlar)

            Console.WriteLine("\n==================================================");
            Console.WriteLine("Programı kapatmak için ENTER tuşuna basın...");
            Console.ReadLine(); 
        }
    }
}
        
    


