# 先import 契約/下單/連接/訊息模組
from ib.ext.Contract import Contract
from ib.ext.Order import Order
from ib.opt import Connection, message

# 處理server訊息用
def error_handler(msg):
    print("Server Error: %s" % msg)

def reply_handler(msg):
    print("Server Response: %s, %s" % (msg.typeName, msg))
    
# 撰寫契約規格，就是說明你要買賣什麼商品
def create_contract(symbol, sec_type, exch, prim_exch, curr):
    contract = Contract()
    # 商品代號
    contract.m_symbol = symbol
    # 商品種類：例如STK代表STOCK
    contract.m_secType = sec_type
    contract.m_exchange = exch
    contract.m_primaryExch = prim_exch
    contract.m_currency = curr
    return contract

# 撰寫委託單，跟在APP下單一樣，要告訴券商你要下哪一種單(市價單/限價單...)，交易量多少，你要買還是賣
def create_order(order_type, quantity, action):
    order = Order()
    order.m_orderType = order_type
    order.m_totalQuantity = quantity
    order.m_action = action
    return order

# 初始化order id，因為對API來說，它會為每一筆委託單建立一個單號，因此在下單的時候，假設第一筆編號是1，那第二筆的編號就不能是1。
order_id = 1

if __name__ == "__main__":
    
    # 連線至TWS登入中的帳戶
    tws_conn = Connection.create(port=4003, clientId=1)
    tws_conn.connect()

    # 連線錯誤的提示訊息
    tws_conn.register(error_handler, 'Error')

    # 將server傳來的訊息都丟給上面寫的handler
    tws_conn.registerAll(reply_handler)

    # 撰寫契約，SMART指的是IB的Smart routing服務，就是請IB去找最好的價格這樣，細節有點複雜，但不影響下單
    contract = create_contract('GOOG', 'STK', 'SMART', 'SMART', 'USD')

    # 撰寫委託單
    order = create_order('MKT', 1, 'BUY')

    # 下單
    tws_conn.placeOrder(order_id, contract, order)
    time.sleep(5)

    # 斷開連接
    tws_conn.disconnect()
    
    # 建立下一個委託單號，不一定要用增加1的方式，只要不重複即可
    order_id += 1