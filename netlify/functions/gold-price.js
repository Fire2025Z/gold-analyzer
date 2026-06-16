exports.handler = async (event, context) => {
  const headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Access-Control-Allow-Methods': 'GET, OPTIONS',
  };

  if (event.httpMethod === 'OPTIONS') {
    return { statusCode: 200, headers, body: '' };
  }

  try {
    // Try multiple sources
    let price = null;
    
    // Source 1: Exchange Rate API
    try {
      const response = await fetch('https://api.exchangerate-api.com/v4/latest/USD');
      const data = await response.json();
      if (data.rates && data.rates.XAU) {
        price = 1 / data.rates.XAU;
        console.log('✅ Gold price from Exchange Rate API:', price);
      }
    } catch (e) {
      console.log('❌ Exchange Rate API failed:', e.message);
    }

    // Source 2: Alternative API (if first failed)
    if (!price) {
      try {
        const response = await fetch('https://api.gold-api.com/price/XAU');
        const data = await response.json();
        if (data.price) {
          price = data.price;
          console.log('✅ Gold price from Gold-API:', price);
        }
      } catch (e) {
        console.log('❌ Gold-API failed:', e.message);
      }
    }

    // Source 3: Another alternative
    if (!price) {
      try {
        const response = await fetch('https://www.goldprice.org/feed/GetJson.aspx?d=USD&m=XAU');
        const data = await response.json();
        if (data.goldprice) {
          price = parseFloat(data.goldprice);
          console.log('✅ Gold price from GoldPrice.org:', price);
        }
      } catch (e) {
        console.log('❌ GoldPrice.org failed:', e.message);
      }
    }

    // Return whatever we got
    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({ 
        price: price,
        timestamp: new Date().toISOString(),
        source: price ? 'success' : 'no data'
      }),
    };
  } catch (error) {
    console.error('Error fetching gold price:', error);
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({ 
        error: 'Failed to fetch gold price',
        price: null 
      }),
    };
  }
};