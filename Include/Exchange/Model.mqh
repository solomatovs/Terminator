//+------------------------------------------------------------------+
//|                                                        Model.mqh |
//|                                 Copyright 2015, Solomatov Sergey |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Solomatov Sergey"
#property link      ""
#property strict


// DATA MODEL -------------------------------------------------------

struct SByte
{
   uchar V[2500];
};

enum EHead
{
   UsersOffset      = 0,
   TerminalsOffset  = 4
};
struct SHead // head info file
{
   uint Users;    // Count users used
   uint Terminals;// Count Terminals file to write
};
enum ETerminal
{
   TerminalOffset = 0,
   LoginOffset = 100,
   CompanyOffset = 104
};
struct STerminal // uniq info for 1 client
{
   char Terminal[100];
   int  Login;
   char Company[100];
   
   void Fill()
   {
      StringToCharArray(TerminalName(), Terminal);
      Login = AccountNumber();
      StringToCharArray(AccountCompany(), Company);
   }
};

// DATA MODEL -------------------------------------------------------

// CHECKER MODEL ----------------------------------------------------

struct MIN_DEVIATION
{
   bool     m_enabler;
   double   m_buyDeviation;
   double   m_sellDeviation;

public:
   void Init(bool enabler = false, double buyDeviation = 0, double sellDeviation = 0)  { m_enabler = enabler; m_buyDeviation = buyDeviation; m_sellDeviation = sellDeviation; }
   void Init(const MIN_DEVIATION& settings)                                            { Init(settings.m_enabler, settings.m_buyDeviation, settings.m_sellDeviation); }
};

struct MIN_GENERAL_FILTER
{
   bool   m_enabler;
   double m_minGeneralSpreads;
   double m_minGeneralPoints;
   
   void Init(bool enabler, double minGeneralSpreads, double minGeneralPoints)
   {
      m_enabler = enabler; m_minGeneralSpreads = minGeneralSpreads; m_minGeneralPoints = minGeneralPoints;
   }
   void Init(const MIN_GENERAL_FILTER& setting)
   {
      Init(setting.m_enabler, setting.m_minGeneralSpreads, setting.m_minGeneralPoints);
   }
   void Init()
   {
      Init(false, 2, 1);
   }
};

struct FILTERS
{
   MIN_DEVIATION  m_minPointDeviation;
   MIN_DEVIATION  m_minSpreadDeviation;
   MIN_GENERAL_FILTER m_minGeneralFilter;
   
   void Init(const MIN_DEVIATION& minPointDeviation, const MIN_DEVIATION& minSpreadDeviation, const MIN_GENERAL_FILTER& minGeneralFilter)
   {
      m_minPointDeviation.Init(minPointDeviation);
      m_minSpreadDeviation.Init(minSpreadDeviation);
      m_minGeneralFilter.Init(minGeneralFilter);
   }
   void Init(const FILTERS& filters)
   {
      Init(filters.m_minPointDeviation, filters.m_minSpreadDeviation, filters.m_minGeneralFilter);
   }
   void Init()
   {
      MIN_DEVIATION  minPointDeviation; minPointDeviation.Init();
      MIN_DEVIATION  minSpreadDeviation;minSpreadDeviation.Init();
      MIN_GENERAL_FILTER minGeneralFilter; minGeneralFilter.Init();
      Init(minPointDeviation, minSpreadDeviation, minGeneralFilter);
   }
};


struct TIMEOUT
{
   bool     m_enabler;
   double   m_timeOutSeconds;
   double   m_timeOutExpertSeconds;
   
   void Init(bool enabler = true, double timeOutSeconds = 30, double timeOutExpertSeconds = 3)   { m_enabler = enabler; m_timeOutSeconds = timeOutSeconds; m_timeOutExpertSeconds = timeOutExpertSeconds; }
   void Init(const TIMEOUT& timeOut)                                                                   { Init(timeOut.m_enabler, timeOut.m_timeOutSeconds, timeOut.m_timeOutExpertSeconds ); }
};

struct NOTIFICATION
{
   bool   m_enabler;
   uint   m_countLimit;        // максимальное количество корректно отправленных сигналов
   double m_resetCountMin;     // количество time, после которых сбрасывается счетчик Count - количество отправленных сигналов
   
public:
   void Init(bool enabler = true, uint countLimit = 1, double resetCountMin = 1) { m_enabler = enabler; m_countLimit = countLimit; m_resetCountMin = resetCountMin; }
   void Init(NOTIFICATION& notification) { Init(notification.m_enabler, notification.m_countLimit, notification.m_resetCountMin); }
};

struct ALERT_NOTIFICATION : NOTIFICATION
{
   void Init(ALERT_NOTIFICATION& settings)
   {
      Init(settings.m_enabler, settings.m_countLimit, settings.m_resetCountMin);
   }
};

struct PUSH_NOTIFICATION : NOTIFICATION
{
   void Init(PUSH_NOTIFICATION& settings)
   {
      Init(settings.m_enabler, settings.m_countLimit, settings.m_resetCountMin);
   }
};

struct EMAIL_NOTIFICATION : NOTIFICATION
{
   string m_header;
   
   void Init(EMAIL_NOTIFICATION& settings)
   {
      Init(settings.m_enabler, settings.m_countLimit, settings.m_resetCountMin); m_header = settings.m_header;
   }
};

struct NOTIFICATIONS
{
   ALERT_NOTIFICATION   m_alert;
   EMAIL_NOTIFICATION   m_email;
   PUSH_NOTIFICATION    m_push;
   
public:
   void Init(ALERT_NOTIFICATION& alert, EMAIL_NOTIFICATION& email, PUSH_NOTIFICATION& push)
   {
      m_alert.Init(alert);
      m_email.Init(email);
      m_push.Init(push);
   }
   void Init(NOTIFICATIONS& notificationSettings)
   {
      Init(notificationSettings.m_alert, notificationSettings.m_email, notificationSettings.m_push);
   }
   void Init()
   {
      ALERT_NOTIFICATION   alert; alert.Init();
      EMAIL_NOTIFICATION   email; email.Init();
      PUSH_NOTIFICATION    push;  push.Init();
      Init(alert, email, push);
   }
};

struct DEVIATION_QUOTES
{
   bool           m_enabler;
   bool           m_logger;
   TIMEOUT        m_timeOut;
   FILTERS        m_filters;
   
   void Init(bool enabler, bool logger, const TIMEOUT& timeOut, const FILTERS& filters)
   {
      m_enabler = enabler;
      m_logger = logger;
      m_timeOut.Init(timeOut);
      m_filters.Init(filters);
   }
   void Init(const DEVIATION_QUOTES& stopQuotesNotificator)
   {
      Init(stopQuotesNotificator.m_enabler, stopQuotesNotificator.m_logger, stopQuotesNotificator.m_timeOut, stopQuotesNotificator.m_filters);
   }
   void Init()
   {
      TIMEOUT timeOut; timeOut.Init();
      FILTERS filters; filters.Init();
      NOTIFICATIONS notifications; notifications.Init();
      Init(false, false, timeOut, filters);
   }
};

struct STOP_QUOTES_NOTIFICATOR : DEVIATION_QUOTES
{
   NOTIFICATIONS  m_notifications;
   
public:
   void Init(bool enabler, bool logger, TIMEOUT& timeOut, FILTERS& filters, NOTIFICATIONS& notifications)
   {
      Init(enabler, logger, timeOut, filters);
      m_notifications.Init(notifications);
   }
   void Init(STOP_QUOTES_NOTIFICATOR& stopQuotesNotificator)
   {
      Init(stopQuotesNotificator.m_enabler, stopQuotesNotificator.m_logger, stopQuotesNotificator.m_timeOut, stopQuotesNotificator.m_filters, stopQuotesNotificator.m_notifications);
   }
   void Init()
   {
      TIMEOUT timeOut; timeOut.Init();
      FILTERS filters; filters.Init();
      NOTIFICATIONS notifications; notifications.Init();
      Init(false, false, timeOut, filters, notifications);
   }
};


enum ETYPE_DHUNTER
{
   m_deviator = 1,
   m_delayer  = 2
};

struct DHUNTER_SIGNAL
{
   double   m_minSpreads;
   double   m_minPoints;
   double   m_minTimeBarrierInMilliSeconds;
   double   m_maxTimeBarrierInMilliSeconds;
   
   void Init(double minSpreads, double minPoints, double minTimeBarrierInMilliSeconds, double maxTimeBarrierInMilliSeconds)
   {
      m_minSpreads = minSpreads; m_minPoints = minPoints; m_minTimeBarrierInMilliSeconds = minTimeBarrierInMilliSeconds; m_maxTimeBarrierInMilliSeconds = maxTimeBarrierInMilliSeconds;
   }
   void Init(const DHUNTER_SIGNAL& setting)
   {
      Init(setting.m_minSpreads, setting.m_minPoints, setting.m_minTimeBarrierInMilliSeconds, setting.m_maxTimeBarrierInMilliSeconds);
   }
   void Init()
   {
      Init(0, 0, 0, 0);
   }
};

struct TRADE_SETTING
{
   double   m_lots;
   int      m_magic;
   int      m_tryOpenCount;
   bool     m_requestVolumeCorrect;
   bool     m_requestPriceCorrect;
   bool     m_requestStoplossCorrect;
   bool     m_requestTakeprofitCorrect;
   
   void Init(
      double   lots,
      int      magic,
      int      tryOpenCount,
      bool     requestVolumeCorrect,
      bool     requestPriceCorrect,
      bool     requestStoplossCorrect,
      bool     requestTakeprofitCorrect)
   {
      
      m_lots = lots; m_magic = magic; m_tryOpenCount = tryOpenCount; m_requestVolumeCorrect = requestVolumeCorrect; m_requestPriceCorrect = requestPriceCorrect;
      m_requestStoplossCorrect = requestStoplossCorrect; m_requestTakeprofitCorrect = requestTakeprofitCorrect;
   }
   void Init(const TRADE_SETTING& setting)
   {
      Init(setting.m_lots, setting.m_magic, setting.m_tryOpenCount, setting.m_requestVolumeCorrect, setting.m_requestPriceCorrect, setting.m_requestStoplossCorrect, setting.m_requestTakeprofitCorrect);
   }
   void Init()
   {
      Init(0, 0, 0, false, false, false, false);
   }
};

struct DHUNTER
{
   bool           m_enabler;
   bool           m_logger;
   int            m_expertTimeOut;
   double         m_minRestrictionPoint;
   ETYPE_DHUNTER  m_type;
   DHUNTER_SIGNAL m_signalOpen;
   DHUNTER_SIGNAL m_signalClose;
   TRADE_SETTING  m_tradeSetting;
   
   void Init(bool enabler, bool logger, int expertTimeOut, double minRestrictionPoint, const ETYPE_DHUNTER& type, const DHUNTER_SIGNAL& signalOpen, const DHUNTER_SIGNAL& signalClose, const TRADE_SETTING& tradeSetting)
   {
      m_enabler = enabler; m_logger = logger; m_expertTimeOut = expertTimeOut; m_minRestrictionPoint = minRestrictionPoint;
      m_type = type;
      m_signalOpen.Init(signalOpen); m_signalClose.Init(signalClose);
      m_tradeSetting.Init(tradeSetting);
   }
   void Init(DHUNTER& setting)
   {
      Init(setting.m_enabler, setting.m_logger, setting.m_expertTimeOut, setting.m_minRestrictionPoint, setting.m_type, setting.m_signalOpen, setting.m_signalClose, setting.m_tradeSetting);
   }
   void Init()
   {
      TIMEOUT timeOut; timeOut.Init();
      FILTERS filters; filters.Init();
      m_enabler = false; m_logger = false; m_expertTimeOut = 3; m_minRestrictionPoint = 0;
      m_type = m_deviator; m_signalOpen.Init(); m_signalClose.Init(); m_tradeSetting.Init();
   }
};

struct AMIR
{
   bool m_enabler;
   
   void Init(bool enabler)
   {
      m_enabler = enabler;
   }
   void Init(AMIR& setting)
   {
      Init(setting.m_enabler);
   }
   void Init()
   {
      Init(false);
   }
};

struct MANAGERS
{
   STOP_QUOTES_NOTIFICATOR m_stopQuotesNotificator;
   DHUNTER                 m_dHunter;
   AMIR                    m_amir;
   
   void Init(STOP_QUOTES_NOTIFICATOR& stopQuotesNotificator, DHUNTER& dHunter, AMIR& amir)
   {
      m_stopQuotesNotificator.Init(stopQuotesNotificator);
      m_dHunter.Init(dHunter);
      m_amir.Init(amir);
   }
   void Init(MANAGERS& managers)
   {
      Init(managers.m_stopQuotesNotificator, managers.m_dHunter, managers.m_amir);
   }
   void Init()
   {
      STOP_QUOTES_NOTIFICATOR stopQuotesNotificator; stopQuotesNotificator.Init();
      DHUNTER dHunter; dHunter.Init();
      AMIR amir; amir.Init();
      Init(stopQuotesNotificator, dHunter, amir);
   }
};
struct MONITOR
{
   // Symbol name in terminal and in memory
   string   m_symbolTerminal;
   string   m_symbolMemory;
   string   m_prefix;
   int      m_UTC;
   bool     m_updater;
   bool     m_master;
   MANAGERS m_managers;
   
public:
   void Init(string     symbolTerminal,
             string     symbolMemory,
             string     prefix,
             int        UTC,
             bool       updater,
             bool       master,
             MANAGERS&  managers)
   {
      m_symbolTerminal = symbolTerminal; m_symbolMemory = symbolMemory; m_prefix = prefix; m_UTC = UTC; m_updater = updater; m_master = master; m_managers.Init(managers);
   }
   void Init(MONITOR& settings)
   {
      Init(settings.m_symbolTerminal, settings.m_symbolMemory, settings.m_prefix, settings.m_UTC, settings.m_updater, settings.m_master, settings.m_managers);
   }
   void Init()
   {
      MANAGERS managers; managers.Init();
      Init("Default", "Default", "Local", 0, false, false, managers);
   }
};


struct MQLRequestClose
{
   int      m_ticket;
   double   m_lots;
   double   m_price;
   MqlTick  m_tick;
   double   m_executionPrice;
   ulong    m_executionMicrosecond;
   int      m_slippage;
   int      m_opposite;
   color    m_arraow_color;

   int      m_error;
   
   void Init(int ticket, double lots, double price, const MqlTick& tick, double executionPrice, ulong executionMicrosecond, int slippage, int opposite, color arraw_color = clrNONE, int error = 0)
   {
      m_ticket = ticket; m_lots = lots; m_price = price;
      m_tick.ask = tick.ask; m_tick.bid = tick.bid; m_tick.last = tick.last; m_tick.time = tick.time; m_tick.volume = tick.volume;
      m_executionPrice = executionPrice; m_executionMicrosecond = executionMicrosecond; m_slippage = slippage; m_opposite = opposite; m_arraow_color = arraw_color; m_error = error;
   }
   void Init(const MQLRequestClose& request)
   {
      Init(request.m_ticket, request.m_lots, request.m_price, request.m_tick, request.m_executionPrice, request.m_executionMicrosecond, request.m_slippage, request.m_opposite, request.m_arraow_color, request.m_error);
   }
   void Init()
   {
      MqlTick tick;
      Init(0, 0, 0, tick, 0, 0, 0, 0);
   }
};

struct MQLOrder;

struct MQLRequestOpen
{
   char     m_symbol[12];
   int      m_cmd;
   double   m_volume;
   double   m_price;
   MqlTick  m_tick;
   double   m_executionPrice;
   ulong    m_executionMicrosecond;
   int      m_slippage;
   double   m_stoploss;
   double   m_takeprofit;
   char     m_comment[50];
   int      m_magic;
   datetime m_expiration;
   color    m_arrow_color;
   int      m_error;
   
   void Init(string symbol, int cmd, double volume, double price, const MqlTick& tick, double executionPrice, ulong executionMicrosecond, int slippage, double stoploss, double takeprofit, string comment = NULL, int magic = 0, datetime expiration = 0, color arrow_color = clrNONE, int error = 0)
   {
      StringToCharArray(symbol, m_symbol); m_cmd = cmd; m_volume = volume; m_price = price;
      m_tick.ask = tick.ask; m_tick.bid = tick.bid; m_tick.last = tick.last; m_tick.time = tick.time; m_tick.volume = tick.volume;
      m_executionPrice = executionPrice; m_executionMicrosecond = executionMicrosecond; m_stoploss = stoploss; m_takeprofit = takeprofit;
      StringToCharArray(comment, m_comment); m_magic = magic; m_expiration = expiration; m_arrow_color = arrow_color; m_error = error;
   }
   void Init(const char& symbol[], int cmd, double volume, double price, const MqlTick& tick, double executionPrice, ulong executionMicrosecond, int slippage, double stoploss, double takeprofit, const char& comment[], int magic = 0, datetime expiration = 0, color arrow_color = clrNONE, int error = 0)
   {
      ArrayCopy(m_symbol, symbol); m_cmd = cmd; m_volume = volume; m_price = price;
      m_tick.ask = tick.ask; m_tick.bid = tick.bid; m_tick.last = tick.last; m_tick.time = tick.time; m_tick.volume = tick.volume;
      m_executionPrice = executionPrice; m_executionMicrosecond = executionMicrosecond; m_stoploss = stoploss; m_takeprofit = takeprofit;
      ArrayCopy(m_comment, comment); m_magic = magic; m_expiration = expiration; m_arrow_color = arrow_color; m_error = error;
   }
   void Init(const MQLRequestOpen& request)
   {
      Init(request.m_symbol, request.m_cmd, request.m_volume, request.m_price, request.m_tick, request.m_executionPrice, request.m_executionMicrosecond, request.m_slippage, request.m_stoploss, request.m_takeprofit, request.m_comment, request.m_magic, request.m_expiration, request.m_arrow_color, request.m_error);
   }
   void Init(const MQLOrder& order)
   {
      MqlTick tick;
      Init(order.m_symbol, order.m_cmd, order.m_volume, order.m_price, tick, 0, 0, 0, order.m_stoploss, order.m_takeprofit, order.m_comment, order.m_magic, order.m_expiration, order.m_arrow_color, 0);
   }
   
   void Init()
   {
      MqlTick tick;
      Init(NULL, 0, 0, 0, tick, 0, 0, 0, 0, 0);
   }
};

struct MQLOrder
{
   int      m_ticket;
   char     m_symbol[12];
   int      m_cmd;
   double   m_volume;
   double   m_price;
   int      m_slippage;
   double   m_stoploss;
   double   m_takeprofit;
   char     m_comment[50];
   int      m_magic;
   datetime m_expiration;
   double   m_profit;
   double   m_swap;
   double   m_commission;
   double   m_closePrice;
   datetime m_openTime;
   datetime m_closeTime;
   color    m_arrow_color;
   
   void Init(int ticket, string symbol, int cmd, double volume, double price, double closePrice, int slippage, double stoploss, double takeprofit, double profit, double swap, double commission, datetime openTime, datetime closeTime, string comment=NULL, int magic=0, datetime expiration=0, color arrow_color = clrNONE)
   {
      m_ticket = ticket; StringToCharArray(symbol, m_symbol); m_cmd = cmd; m_volume = volume; m_price = price; m_closePrice = closePrice; m_stoploss = stoploss; m_takeprofit = takeprofit;
      m_profit = profit; m_swap = swap; m_commission = commission; m_openTime = openTime; m_closeTime = closeTime;
      StringToCharArray(comment, m_comment); m_magic = magic; m_expiration = expiration; m_arrow_color = arrow_color;
   }
   void Init(int ticket, const char& symbol[], int cmd, double volume, double price, double closePrice, int slippage, double stoploss, double takeprofit, double profit, double swap, double commission, datetime openTime, datetime closeTime, const char& comment[], int magic=0, datetime expiration=0, color arrow_color = clrNONE)
   {
      m_ticket = ticket; ArrayCopy(m_symbol, symbol); m_cmd = cmd; m_volume = volume; m_price = price; m_closePrice = closePrice; m_stoploss = stoploss; m_takeprofit = takeprofit;
      m_profit = profit; m_swap = swap; m_commission = commission; m_openTime = openTime; m_closeTime = closeTime;
      ArrayCopy(m_comment, comment); m_magic = magic; m_expiration = expiration; m_arrow_color = arrow_color;
   }
   void Init(const MQLOrder& order)
   {
      Init(order.m_ticket, order.m_symbol, order.m_cmd, order.m_volume, order.m_price, order.m_closePrice, order.m_slippage, order.m_stoploss, order.m_takeprofit, order.m_profit, order.m_swap, order.m_commission, order.m_openTime, order.m_closeTime, order.m_comment, order.m_magic, order.m_expiration, order.m_arrow_color);
   }
   void Init(const MQLRequestOpen& request)
   {
      Init(0, request.m_symbol, request.m_cmd, request.m_volume, request.m_price, 0, request.m_slippage, request.m_stoploss, request.m_takeprofit, 0, 0, 0, 0, 0, request.m_comment, request.m_magic, request.m_expiration, request.m_arrow_color);
   }
   void Init()
   {
      Init(0, NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
   }
   string ToString()
   {
      return StringConcatenate(m_ticket, ": Type: ", TypeToString(m_cmd), "; Lots: ", DoubleToString(m_volume, 2), "; Magic: ", m_magic, "; Profit: ", DoubleToString(m_profit + m_swap + m_commission, 2));
   }
   string TypeToString(int type)
   {
      switch(type)
      {
         case OP_BUY: return "BUY"; break;
         case OP_SELL: return "SELL"; break;
         case OP_BUYLIMIT: return "BUY_LIMIT"; break;
         case OP_BUYSTOP: return "BUY_STOP"; break;
         case OP_SELLLIMIT: return "SELL_LIMIT"; break;
         case OP_SELLSTOP: return "SELL_STOP"; break;
      }
      return "Неизвестный тип ордера";
   }
};

enum EData
{
   DataTerminalOffset         = 0,
   DataTSymboOffset           = 204,
   DataMqlTickOffset          = 216,
   DataLastUpdateQuoteOffset  = 256,
   DataTimeOutQuote           = 264,
   DataMqlTickBeforeOffset    = 272,
   DataLastUpdateExpert       = 312,
   DataisTradeAllowed         = 320,
   DataMaster                 = 321,
   DataLastTimeTransaction    = 322,
   DataOrder                  = 331,
   DataOrderHistory           = 1181,
};
struct SData // field info for 1 terminal
{
   STerminal   Terminal;             // login info
   char        TSymbol[12];          // Symbol Terminal info
   MqlTick     MQLTick;              // tick current info
   ulong       LastUpdateQuote;      // LastUpdateMickrosecondQuote
   ulong       TimeOutQuote;         // TimeOutMickrosecondQuote
   MqlTick     MQLTickBefore;        // tick before info
   datetime    LastUpdateExpert;     // Last time update expert
   bool        isTradeAllowed;       // Trade allow symbol on this time
   bool        Master;               // Master Terminal or Slave Terminal
   datetime    LastTimeTransaction;  // Last Time Transaction
   MQLOrder    Orders[5];            // Open orders in monitor
   MQLOrder    OrdersHistory[5];     // Last history orders in monitor
   
   void Fill(MONITOR& monitor)
   {
      Terminal.Fill();
      SymbolInfoTick(monitor.m_symbolTerminal, MQLTick);
      StringToCharArray(monitor.m_symbolTerminal, TSymbol);
      LastUpdateExpert = TimeGMT();
      isTradeAllowed = IsTradeAllowed(monitor.m_symbolTerminal, TimeGMT() + (monitor.m_UTC * 3600));
      Master = monitor.m_master;
      OrdersFill(monitor);
      OrdersHistoryFill(monitor);
      SetLastTimeTransaction(monitor);
   }
   void OrdersFill(MONITOR& monitor)
   {
      int total = OrdersTotal();
      int size = ArraySize(Orders);
      for (int i = 0; i < size; i++)
      {
         Orders[i].Init();
      }
      
      int j = 0;
      for (int i = 0; i < total; i++)
      {
         bool select = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
         if (!select)   continue;
         
         if (StringCompare(OrderSymbol(), monitor.m_symbolTerminal) == 0)
         {
            Orders[j].Init(OrderTicket(), OrderSymbol(), OrderType(), OrderLots(), OrderOpenPrice(), OrderClosePrice(), 0, OrderStopLoss(), OrderTakeProfit(), OrderProfit(), OrderSwap(), OrderCommission(), OrderOpenTime(), OrderCloseTime(), OrderComment(), OrderMagicNumber(), OrderExpiration(), clrNONE);
            j++;
            if (j >= size)   break;
         }
      }
   }
   
   void OrdersHistoryFill(MONITOR& monitor)
   {
      int total = OrdersHistoryTotal();
      int size = ArraySize(OrdersHistory);
      for (int i = 0; i < size; i++)
      {
         OrdersHistory[i].Init();
      }
      
      int j = 0;
      for (int i = 0; i < total; i++)
      {
         bool select = OrderSelect(total - i, SELECT_BY_POS, MODE_HISTORY);
         if (!select)   continue;
         
         if (StringCompare(OrderSymbol(), monitor.m_symbolTerminal) == 0)
         {
            OrdersHistory[j].Init(OrderTicket(), OrderSymbol(), OrderType(), OrderLots(), OrderOpenPrice(), OrderClosePrice(), 0, OrderStopLoss(), OrderTakeProfit(), OrderProfit(), OrderSwap(), OrderCommission(), OrderOpenTime(), OrderCloseTime(), OrderComment(), OrderMagicNumber(), OrderExpiration(), clrNONE);
            j++;
            if (j >= size)   break;
         }
      }
   }
   
   void SetLastTimeTransaction(MONITOR& monitor)
   {
      int utcOffset = TimeGMTOffset();
      if (utcOffset != (monitor.m_UTC * 3600)) utcOffset = monitor.m_UTC * 3600;
      
      LastTimeTransaction = 0;
      for (int i = 0; i < ArraySize(Orders); i++)
      {
         if (Orders[i].m_ticket <= 0) continue;
         
         datetime time = Orders[i].m_openTime - utcOffset;
         if (time > LastTimeTransaction) LastTimeTransaction = time;
      }
      for (int i = 0; i < ArraySize(OrdersHistory); i++)
      {
         if (OrdersHistory[i].m_ticket <= 0) continue;
         
         datetime time = OrdersHistory[i].m_closeTime - utcOffset;
         if (time > LastTimeTransaction) LastTimeTransaction = time;
      }
   }
   
   string OrdersToString(int magicNumberFilter = -1)
   {
      string text = NULL; int j = 0;
      for (int i = 0; i < ArraySize(Orders); i++)
      {
         if (Orders[i].m_ticket <= 0 || (Orders[i].m_magic != magicNumberFilter && magicNumberFilter != -1)) continue;
         j++; if (j > 1)  text += "\n";
         text += Orders[i].ToString();
      }
      return text;
   }
   string OrdersHistoryToString(int magicNumberFilter = -1)
   {
      string text = NULL; int j = 0;
      for (int i = 0; i < ArraySize(OrdersHistory); i++)
      {
         if (OrdersHistory[i].m_ticket <= 0 || (OrdersHistory[i].m_magic != magicNumberFilter && magicNumberFilter != -1)) continue;
         j++; if (j > 1)  text += "\n";
         text += OrdersHistory[i].ToString();
      }
      return text;
   }
};

struct FileStruct // file structe
{
   SHead Head;
   SData Data[];
};



// CHECKER MODEL -----------------------------------------------------

// NOTIFICATION MODEL ------------------------------------------------


// NOTIFICATION MODEL ------------------------------------------------

// SETTINGS EXPERT ---------------------------------------------------


struct EXPERT
{
   int      m_updateMilliSecondsExpert;
   string   m_configPath;
   MONITOR  m_monitor;
   
   void Init(int updateMilliSecondsExpert, string configPath, MONITOR& monitor)
   {
      m_updateMilliSecondsExpert = updateMilliSecondsExpert;
      m_configPath = configPath;
      m_monitor.Init(monitor);
   }
   void Init(EXPERT& expert)
   {
      Init(expert.m_updateMilliSecondsExpert, expert.m_configPath, expert.m_monitor);
   }
};
// SETTINGS EXPERT ---------------------------------------------------
