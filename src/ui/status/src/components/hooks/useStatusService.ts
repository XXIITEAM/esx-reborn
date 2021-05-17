import { useSetRecoilState } from 'recoil';
import { statusState } from './state';
import { useStatus } from './useStatus';
import { useNuiEvent } from '../../nui-events/hooks/useNuiEvent';

export const useStatusService = (): any => {
  const setStatusState = useSetRecoilState(statusState.setStatus);
  useNuiEvent('STATUS', 'setStatus', setStatusState);
  return useStatus();
}