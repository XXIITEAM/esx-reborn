import { atom } from 'recoil';

export const statusState = {
  setStatus: atom({
    key: 'setStatus',
    default: []
  })
}