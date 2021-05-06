import search from "./search";
import getAllCombos from "./get-all-combos";

import type { FormattedApiResponse } from "./types";

export default async function random(
  query = ""
): Promise<FormattedApiResponse> {
  let combos;

  if (query) {
    const result = await search(query);
    combos = result.combos;
  } else {
    combos = await getAllCombos();
  }

  const randomIndex = Math.floor(Math.random() * combos.length);

  return combos[randomIndex];
}
