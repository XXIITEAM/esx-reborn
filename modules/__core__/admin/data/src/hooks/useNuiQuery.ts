import { useCallback, useMemo, useState } from "react";

export const useNuiQuery = (action: string) => {
  // Hack to allow usage of nuiQuery in browser.
  const isBrowser = useMemo(() => {
    let _isBrowser = true;
    try {
      _isBrowser = (window as any).nuiTargetGame !== "gta5";
    } catch (error) {
      console.error(error);
    }

    return _isBrowser;
  }, []);

  const query = useCallback(
    (payload?: unknown) => {
      if (isBrowser) {
        console.log(`[MOCK FETCH CALL] - ${action}`, payload);
        return;
      }

      // Todo make this promised. The other frame should responde with an event I guess ?
      return window.parent.postMessage(
        { action: action, data: payload || {} },
        "*"
      );
    },
    [action, isBrowser]
  );

  return [query];
};
