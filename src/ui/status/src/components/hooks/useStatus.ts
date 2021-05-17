import { useRecoilValue } from 'recoil';
import { statusState } from './state';

export const useStatus = (): any => {
  const status = useRecoilValue(statusState.setStatus);
  return status;
}