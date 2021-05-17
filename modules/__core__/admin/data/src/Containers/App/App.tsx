import React, { useEffect, useMemo, useState } from "react";
import {
  Button,
  Container,
  Form,
  Header,
  Icon,
  Label,
  Menu,
  Modal,
  Tab,
  Table,
} from "semantic-ui-react";
import styled from "styled-components";
import { useNuiEvent } from "../../hooks/useNuiEvent";
import { useNuiQuery } from "../../hooks/useNuiQuery";
import { CopyToClipboard } from "react-copy-to-clipboard";
import { playersMock } from "../../mocks/player-list.mock";
import { ReasonModal } from "../../components/reason-modal";

const ScollableDiv = styled.div`
  overflow-y: scroll;
  max-height: 70vh !important;

  /* Track */
  ::-webkit-scrollbar-track {
    background: rgba(60, 60, 60, 0.8) !important;
  }

  /* Handle */
  ::-webkit-scrollbar-thumb {
    background: orange;
  }

  /* Handle on hover */
  ::-webkit-scrollbar-thumb:hover {
    background: #555;
  }
`;

const CustomContainer = styled(Container)`
  background-color: rgba(0, 0, 0, 0.8);
  padding: 16px;
  margin-top: 24px;
  overflow-y: hidden;
  position: relative;
  max-height: 97vh !important;
`;

const CustomTab = styled(Tab)`
  border-color: rgba(60, 60, 60, 0.8) !important;
  a.active {
    background-color: rgba(60, 60, 60, 0.8) !important;
    border-color: black !important;
  }
  color: white;

  max-height: 80vh !important;
`;

const CustomMenuItem = styled(Menu.Item)`
  color: white !important;
`;

const CustomTable = styled(Table)`
  th,
  td {
    border-color: rgba(0, 0, 0, 0.8);
    background-color: rgba(60, 60, 60, 0.8) !important;
  }
  th {
    color: #cc9839 !important;
  }
  td {
    color: white !important;
  }
`;

const CloseX = styled.span`
  color: red;
  position: absolute;
  top: 10px;
  right: 10px;
`;

export type Player = {
  name: string;
  identity?: {
    firstName: string;
    lastName: string;
  };
  identifier: string;
  source: string;
};

const App = () => {
  const [players, setPlayers] = useState<Player[]>([]);
  const [modalMetadata, setModalMetadata] = useState<{
    action?: string;
    playerId?: string;
    isOpened: boolean;
  }>({ isOpened: false });

  const { emulate } = useNuiEvent(
    (event) => setPlayers(event.data),
    "updatePlayers"
  );

  useEffect(() => {
    setTimeout(() => emulate(playersMock), 0);
  }, []);

  const [closeQuery] = useNuiQuery("close");
  const [kickQuery] = useNuiQuery("kick");
  const [banQuery] = useNuiQuery("ban");

  const panes = useMemo(() => {
    return [
      {
        menuItem: (
          <CustomMenuItem key="players">
            <Icon name="users" />
            Players<Label color="orange">{players ? players.length : 0}</Label>
          </CustomMenuItem>
        ),
        render: () => (
          <Tab.Pane className="tab-pane-dark">
            <ScollableDiv>
              <CustomTable celled fixed singleLine>
                <Table.Header>
                  <Table.Row>
                    <Table.HeaderCell>Id</Table.HeaderCell>
                    <Table.HeaderCell>Nickname</Table.HeaderCell>
                    <Table.HeaderCell>RP Name</Table.HeaderCell>
                    <Table.HeaderCell>Identifier</Table.HeaderCell>
                    <Table.HeaderCell>Actions</Table.HeaderCell>
                  </Table.Row>
                </Table.Header>

                <Table.Body>
                  {players.map((player) => (
                    <Table.Row key={player.source}>
                      <Table.Cell>{player.source}</Table.Cell>
                      <Table.Cell>{player.name}</Table.Cell>

                      <Table.Cell>
                        {player.identity?.firstName} {player.identity?.lastName}
                      </Table.Cell>
                      <Table.Cell>
                        <CopyToClipboard text={player.identifier}>
                          <Icon name="clipboard" />
                        </CopyToClipboard>
                        {player.identifier}
                      </Table.Cell>
                      <Table.Cell>
                        <Button
                          onClick={() =>
                            setModalMetadata({
                              action: "kick",
                              isOpened: true,
                              playerId: player.source,
                            })
                          }
                          size="mini"
                          color="orange"
                        >
                          Kick
                        </Button>
                        <Button
                          onClick={() =>
                            setModalMetadata({
                              action: "ban",
                              isOpened: true,
                              playerId: player.source,
                            })
                          }
                          size="mini"
                          color="red"
                        >
                          Ban
                        </Button>
                      </Table.Cell>
                    </Table.Row>
                  ))}
                </Table.Body>
              </CustomTable>
            </ScollableDiv>
          </Tab.Pane>
        ),
      },
    ];
  }, [players]);

  return (
    <CustomContainer>
      <div>
        <Header as="h2" icon textAlign="center">
          <Icon className="white" name="setting" circular />
          <Header.Content className="white">Admin panel</Header.Content>
        </Header>
        <CloseX>
          <Button
            onClick={() => closeQuery()}
            color="red"
            circular
            icon="close"
            size="big"
          />
        </CloseX>
      </div>
      <CustomTab panes={panes} />
      <ReasonModal
        isOpened={modalMetadata.isOpened}
        onClose={() => setModalMetadata({ isOpened: false })}
        onConfirm={(reason) => {
          if (modalMetadata.action === "kick") {
            kickQuery({ id: modalMetadata.playerId, reason });
          } else if (modalMetadata.action === "ban") {
            banQuery({ id: modalMetadata.playerId, reason });
          }

          setModalMetadata({ isOpened: false });
        }}
        action={modalMetadata.action}
        playerId={modalMetadata.playerId}
      />
    </CustomContainer>
  );
};

export default App;
