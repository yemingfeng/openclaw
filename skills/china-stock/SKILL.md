---
name: china-stock
description: 获取国内A股股票实时行情、历史数据、技术指标和新闻资讯。支持沪深A股、港股、科创板，无需API Key。
metadata:
  {
    "openclaw":
      {
        "emoji": "📈",
        "requires": { "bins": ["python3"], "anyBins": ["pip3"] },
        "install":
          [
            {
              "id": "pip3",
              "kind": "pip3",
              "package": "akshare",
              "bins": ["pip3"],
              "label": "Install AkShare (pip3)",
            },
          ],
      },
  }
---

# 中国股票行情 (China Stock)

基于 **AkShare** 和 **腾讯财经API** 的免费股票数据查询工具，无需注册和API Key。

## 快速开始

### 1. 安装依赖

```bash
# 安装 AkShare (首次使用)
pip3 install akshare -q
```

### 2. 实时行情查询

#### 腾讯财经API (推荐，实时数据)

```bash
# 查询单只股票 (示例: 贵州茅台 600519)
curl -s "http://qt.gtimg.cn/q=sh600519"

# 查询多只股票
curl -s "http://qt.gtimg.cn/q=sh600519,sz000001,sh601318"

# 港股查询 (示例: 腾讯控股 00700)
curl -s "http://qt.gtimg.cn/q=hk00700"
```

**返回字段说明**：

- 股票名称、当前价格、涨跌额、涨跌幅
- 今开、昨收、最高、最低
- 成交量(手)、成交额
- 日期、时间

#### AkShare查询

```python
# 实时行情
python3 -c "import akshare as ak; print(ak.stock_zh_a_spot_em())"

# 单只股票实时数据
python3 -c "import akshare as ak; print(ak.stock_zh_a_spot_em()).to_string()"
```

### 3. 历史数据查询

```python
# 日K线数据
python3 << 'EOF'
import akshare as ak
df = ak.stock_zh_a_hist(symbol="600519", period="daily", start_date="20250101", adjust="qfq")
print(df.tail(10).to_string())
EOF

# 周K线/月K线
python3 << 'EOF'
import akshare as ak
df = ak.stock_zh_a_hist(symbol="600519", period="weekly", adjust="qfq")
print(df.to_string())
EOF
```

**参数说明**：

- `symbol`: 股票代码 (6位数字)
- `period`: daily(日线) / weekly(周线) / monthly(月线)
- `adjust`: ""(不复权) / "qfq"(前复权) / "hfq"(后复权)
- `start_date`: 起始日期 (YYYYMMDD格式)

### 4. 技术指标

```python
# 获取历史数据后计算技术指标
python3 << 'EOF'
import akshare as ak
import pandas as pd

df = ak.stock_zh_a_hist(symbol="600519", period="daily", adjust="qfq")

# 计算移动平均线
df['MA5'] = df['收盘'].rolling(window=5).mean()
df['MA10'] = df['收盘'].rolling(window=10).mean()
df['MA20'] = df['收盘'].rolling(window=20).mean()

print(df[['日期', '收盘', 'MA5', 'MA10', 'MA20']].tail(10).to_string())
EOF
```

### 5. 股票新闻资讯

```python
# 东方财富个股新闻
python3 << 'EOF'
import akshare as ak
df = ak.stock_news_em(symbol="600519")
print(df.head(10).to_string())
EOF

# 新浪财经新闻
python3 << 'EOF'
import akshare as ak
df = ak.stock_news_sina(symbol="sh600519")
print(df.head(10).to_string())
EOF
```

### 6. 自选股管理

```bash
# 创建自选股文件
echo "sh600519" > ~/.openclaw/watchlist.txt  # 贵州茅台
echo "sz000001" >> ~/.openclaw/watchlist.txt  # 平安银行
echo "sh601318" >> ~/.openclaw/watchlist.txt  # 中国平安

# 批量查询自选股
WATCHLIST=$(cat ~/.openclaw/watchlist.txt | tr '\n' ',')
curl -s "http://qt.gtimg.cn/q=${WATCHLIST%,}"
```

### 7. 常用查询示例

#### 查看股票基本信息

```python
python3 << 'EOF'
import akshare as ak
df = ak.stock_individual_info_em(symbol="600519")
print(df.to_string())
EOF
```

#### 查看资金流向

```python
python3 << 'EOF'
import akshare as ak
df = ak.stock_individual_fund_flow(stock="600519", market="sh")
print(df.head(10).to_string())
EOF
```

#### 查看涨停板/跌停板

```python
python3 << 'EOF'
import akshare as ak
df = ak.stock_zt_pool_em(date="20250204")
print(df.to_string())
EOF
```

#### 查看龙虎榜数据

```python
python3 << 'EOF'
import akshare as ak
df = ak.stock_lhb_detail_em(start_date="20250101", end_date="20250204")
print(df.head(20).to_string())
EOF
```

## 股票代码格式

| 市场     | 前缀 | 示例     | 说明                 |
| -------- | ---- | -------- | -------------------- |
| 上海主板 | sh   | sh600519 | 600xxx/601xxx/603xxx |
| 深圳主板 | sz   | sz000001 | 000xxx               |
| 中小板   | sz   | sz002415 | 002xxx               |
| 创业板   | sz   | sz300750 | 300xxx               |
| 科创板   | sh   | sh688981 | 688xxx               |
| 北交所   | bj   | bj832566 | 43xxxx/83xxxx/87xxxx |
| 港股     | hk   | hk00700  | 4-5位数字            |

## AkShare常用接口速查

```python
# 实时行情
ak.stock_zh_a_spot_em()

# 历史K线
ak.stock_zh_a_hist(symbol="600519", period="daily", adjust="qfq")

# 分时数据
ak.stock_zh_a_minute(symbol="600519", period="1", adjust="")

# 财务数据
ak.stock_balance_sheet_by_yearly_em(symbol="600519")

# 股东信息
ak.stock_holder_number_em(symbol="600519")

# 业绩预告
ak.stock_yjyg_em()

# IPO新股
ak.stock_new_ipo_em()
```

## 注意事项

1. **频率限制**：避免过于频繁的请求，建议间隔1秒以上
2. **数据延迟**：免费数据通常有15-20秒延迟
3. **盘后维护**：交易所盘后维护时段数据可能为空
4. **编码问题**：腾讯API返回为GBK编码，AkShare已自动处理
5. **Python依赖**：AkShare需要 `pandas` 和 `requests`

## 数据源说明

- **腾讯财经API**: 实时行情数据，稳定可靠
- **AkShare**: 整合新浪/东方财富等数据源，功能全面
- **东方财富**: 补充数据（龙虎榜、资金流向等）
- **新浪财经**: 备用数据源

## 参考文档

- AkShare官方文档: https://akshare.akfamily.xyz/
- 腾讯财经接口说明: http://qt.gtimg.cn/
- 东方财富数据: https://data.eastmoney.com/
