//+------------------------------------------------------------------+
//|                                                 SQLiteTest.mq4   |
//|                    DatabaseMT4.mqh 기능 테스트 스크립트            |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, User"
#property strict

// 1. 헤더 파일 포함
#include <DatabaseMT4.mqh>

void OnStart()
{
   string db_name = "MT4_TestDB.db";
   // string db_name = "D:\\MyTradingData\\Global_Stats.db";

   // 2. DB 열기 (파일이 없으면 생성됨)
   int db_handle = DatabaseOpen(db_name, DATABASE_OPEN_READWRITE | DATABASE_OPEN_CREATE);

   if(db_handle == INVALID_HANDLE) {
      Print("데이터베이스 오픈 실패!");
      return;
   }
   Print("데이터베이스 오픈 성공: ", db_name);

   // 3. 테이블 생성
   string sql_create = "CREATE TABLE IF NOT EXISTS TRADES ("
                       "ID INTEGER PRIMARY KEY AUTOINCREMENT,"
                       "SYMBOL TEXT,"
                       "TYPE INTEGER,"
                       "PRICE REAL);";

   if(DatabaseExecute(db_handle, sql_create)) {
      Print("테이블 생성 완료");
   }

   // 4. 데이터 삽입 (트랜잭션 사용)
   DatabaseTransactionBegin(db_handle);

   string sql_insert = "INSERT INTO TRADES (SYMBOL, TYPE, PRICE) VALUES ('EURUSD', 0, 1.0850);";
   DatabaseExecute(db_handle, sql_insert);

   sql_insert = "INSERT INTO TRADES (SYMBOL, TYPE, PRICE) VALUES ('GBPUSD', 1, 1.2640);";
   DatabaseExecute(db_handle, sql_insert);

   DatabaseTransactionCommit(db_handle);
   Print("데이터 삽입 완료");

   // 5. 데이터 조회 (DatabasePrepare & DatabaseRead)
   string sql_select = "SELECT * FROM TRADES;";
   int stmt = DatabasePrepare(db_handle, sql_select);

   if(stmt != INVALID_HANDLE) {
      Print("--- 데이터 조회 시작 ---");
      while(DatabaseRead(stmt)) {
         int id = DatabaseColumnInteger(stmt, 0);
         // 참고: Text 함수는 포인터 처리가 필요하므로 여기선 제외하고 수치 데이터 위주 테스트
         int type = DatabaseColumnInteger(stmt, 2);
         double price = DatabaseColumnDouble(stmt, 3);

         PrintFormat("ID: %d, Type: %d, Price: %.4f", id, type, price);
      }
      DatabaseFinalize(stmt);
   }

   // 6. DB 닫기
   DatabaseClose(db_handle);
   Print("데이터베이스 테스트 종료");
}
