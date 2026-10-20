"use client";

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  return (
    <main>
      <p className="eyebrow">Docker lab · Web1</p>
      <h1>Could not reach Api1</h1>
      <p className="error">{error.message}</p>
      <p className="lede">
        Start Api1 first, or use <code>docker compose up --build</code> so Web1
        can call <code>http://api1:8080</code> on the Compose network.
      </p>
      <button type="button" onClick={() => reset()}>
        Try again
      </button>
    </main>
  );
}
