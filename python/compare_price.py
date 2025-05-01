
import requests
from bs4 import BeautifulSoup

# Replace with your own Bing API key
subscription_key = 'YOUR_BING_API_KEY'
search_url = "https://api.bing.microsoft.com/v7.0/search"

def get_search_results(query):
    headers = {"Ocp-Apim-Subscription-Key": subscription_key}
    params = {"q": query, "count": 50}
    response = requests.get(search_url, headers=headers, params=params)
    response.raise_for_status()
    search_results = response.json()
    return search_results.get('webPages', {}).get('value', [])

def extract_urls_from_results(results):
    urls = [result['url'] for result in results]
    return urls

if name == "__main__":
    query = "site:.vn phòng khám online"
    search_results = get_search_results(query)
    urls = extract_urls_from_results(search_results)
    print("Found URLs:")
    for url in urls:
        print(url)


def fetch_prices_from_web(url):
    response = requests.get(url)
    soup = BeautifulSoup(response.text, 'html.parser')

    prices = []

    # Update this to match the actual HTML structure of the pages
    for price_tag in soup.find_all('span', class_='price'):
        price_text = price_tag.get_text()
        # Convert price text to integer
        price = int(price_text.replace('VND', '').replace(',', '').strip())
        prices.append(price)

    return prices

def get_prices_from_multiple_sites(urls):
    all_prices = []
    for url in urls:
        try:
            prices = fetch_prices_from_web(url)
            all_prices.extend(prices)
        except Exception as e:
            print(f"Failed to fetch data from {url}: {e}")
    return all_prices

def calculate_average_price(prices):
    if not prices:
        return 0
    return sum(prices) / len(prices)

if name == "__main__":
    # Use previously obtained URLs
    # urls = [...]  # Replace with URLs from Bing search results

    # Example for demonstration purposes
    urls = [
        'https://example-clinic-website1.com/services',
        'https://example-clinic-website2.com/services',
    ]

    # Fetch all prices
    all_prices = get_prices_from_multiple_sites(urls)

    # Calculate average price
    average_price = calculate_average_price(all_prices)

    print(f"Giá trung bình ngành của các trang web phòng khám online là: {average_price:.2f} VND")
