import '../domain/conversation_entity.dart';

final mockConversations = <ConversationEntity>[
  const ConversationEntity(
    id: 'conv-001',
    contactId: 'comp-001',
    contactName: 'Distribuidora El Norte',
    route: 'Quito → Guayaquil',
    lastMessage: 'Hola, ¿sigue disponible el camión para el 15?',
    time: '10:30',
    unreadCount: 2,
    isOnline: true,
  ),
  const ConversationEntity(
    id: 'conv-002',
    contactId: 'comp-002',
    contactName: 'Textiles Andes S.A.',
    route: 'Guayaquil → Cuenca',
    lastMessage: 'Perfecto, confirmo la carga.',
    time: 'Ayer',
    unreadCount: 0,
    isOnline: false,
  ),
  const ConversationEntity(
    id: 'conv-003',
    contactId: 'comp-004',
    contactName: 'Pescados del Pacífico',
    route: 'Manta → Quito',
    lastMessage: '¿Tienes disponibilidad para el viernes?',
    time: 'Lun',
    unreadCount: 1,
    isOnline: true,
  ),
  const ConversationEntity(
    id: 'conv-004',
    contactId: 'comp-005',
    contactName: 'Agro Sur Loja',
    route: 'Loja → Guayaquil',
    lastMessage: 'El precio está bien. ¿Cuándo podemos arrancar?',
    time: 'Dom',
    unreadCount: 0,
    isOnline: false,
  ),
  const ConversationEntity(
    id: 'conv-005',
    contactId: 'comp-003',
    contactName: 'Constructora Chimborazo',
    route: 'Ambato → Quito',
    lastMessage: 'Necesitamos el cargamento urgente.',
    time: 'Sáb',
    unreadCount: 0,
    isOnline: false,
  ),
];

final mockMessages = <String, List<MessageEntity>>{
  'comp-001': [
    const MessageEntity(
        id: 'm1', text: 'Buenos días, vi su carga en RutaLink.', time: '10:00', isMe: true),
    const MessageEntity(
        id: 'm2',
        text: 'Hola, ¿sigue disponible el camión para el 15?',
        time: '10:28',
        isMe: false),
    const MessageEntity(
        id: 'm3', text: 'Sí, tengo disponibilidad para esa fecha.', time: '10:30', isMe: true),
  ],
  'comp-002': [
    const MessageEntity(
        id: 'm4',
        text: 'Hola, me interesa la carga de textiles.',
        time: 'Ayer 09:15',
        isMe: true),
    const MessageEntity(
        id: 'm5',
        text: '¿Tiene camión de 5 toneladas disponible?',
        time: 'Ayer 09:16',
        isMe: true),
    const MessageEntity(
        id: 'm6', text: 'Sí, tenemos. ¿Cuándo puede salir?', time: 'Ayer 11:00', isMe: false),
    const MessageEntity(
        id: 'm7', text: 'Perfecto, confirmo la carga.', time: 'Ayer 14:30', isMe: false),
  ],
};
