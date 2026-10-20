type Item = {
  id: number;
  title: string;
  description: string;
};

type ItemsResponse = {
  instance: string;
  hostname?: string;
  items: Item[];
};

async function getItems(): Promise<ItemsResponse> {
  const base = process.env.API_URL ?? "http://localhost:8080";
  const res = await fetch(`${base}/api/items`, { cache: "no-store" });
  if (!res.ok) {
    throw new Error(`API returned ${res.status}`);
  }
  return res.json();
}

export default async function Home() {
  const site = process.env.SITE_NAME ?? "Web1";
  const apiUrl = process.env.API_URL ?? "http://localhost:8080";
  const { instance, hostname, items } = await getItems();
  const apiLabel = hostname ? `${instance} (${hostname})` : instance;

  return (
    <main>
      <p className="eyebrow">Docker lab · {site}</p>
      <h1>Lessons from {instance} (v2)</h1>
      <p className="lede">
        This container is <code>{site}</code>. It loaded static data from{" "}
        <code>{apiLabel}</code> at <code>{apiUrl}</code>. Refresh to see another
        replica if a routing mesh or load balancer is in front.
      </p>
      <p className="badge">replica: {site} → {instance}</p>
      <ul className="cards">
        {items.map((item) => (
          <li key={item.id} className="card">
            <span className="id">{String(item.id).padStart(2, "0")}</span>
            <h2>{item.title}</h2>
            <p>{item.description}</p>
          </li>
        ))}
      </ul>
    </main>
  );
}
