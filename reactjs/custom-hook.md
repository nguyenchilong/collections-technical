# Custom Hook
- Create new Hook file
```javascript
const useProducts = () => {
	const [products, setProducts] = useState([]);
	useEffect(() => {
		fetch('/api/products')
			.then (res => res.json())
			.then (data => setProducts(data));	
	}, []);
	return products;
}
```
- Use the hook in a Container Component
```jsx
function ProductContainer() {
	const products = useProducts();
	return <ProductList products={products} />;
｝
```
- Use the hook in a Presentational Component
```jsx
function ProductList({ products }) {
	return (
		<ul>
			{products.map((product) => (
				<li key={product.id}>{product.name}</li>
			))}
		</ul>
	);
}
```
